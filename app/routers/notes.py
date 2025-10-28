from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_current_user
from app.database import get_db
from app.logger import log_request, log_error

router = APIRouter()


def get_or_create_tag(db: Session, tag_name: str) -> models.Tag:
    """Get existing tag or create new one"""
    tag = db.query(models.Tag).filter(models.Tag.name == tag_name).first()
    if not tag:
        tag = models.Tag(name=tag_name)
        db.add(tag)
        db.flush()
    return tag


@router.get("/notes", response_model=List[schemas.Note])
async def get_notes(
    search: Optional[str] = Query(None, description="Search in title"),
    tag: Optional[str] = Query(None, description="Filter by tag name"),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Get all notes for current user
    
    - **search**: optional search query for note titles
    - **tag**: optional filter by tag name
    """
    try:
        log_request("GET", "/notes", user=current_user.username)
        
        query = db.query(models.Note).filter(models.Note.user_id == current_user.id)
        
        # Apply search filter
        if search:
            query = query.filter(models.Note.title.ilike(f"%{search}%"))
        
        # Apply tag filter
        if tag:
            query = query.join(models.Note.tags).filter(models.Tag.name == tag)
        
        notes = query.order_by(models.Note.updated_at.desc()).all()
        return notes
    
    except Exception as e:
        log_error(e, "get_notes")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving notes"
        )


@router.post("/notes", response_model=schemas.Note, status_code=status.HTTP_201_CREATED)
async def create_note(
    note: schemas.NoteCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Create a new note
    
    - **title**: note title (1-200 characters)
    - **content**: note content
    - **tags**: optional list of tag names
    """
    try:
        log_request("POST", "/notes", user=current_user.username)
        
        # Create note
        db_note = models.Note(
            title=note.title,
            content=note.content,
            user_id=current_user.id
        )
        
        # Add tags
        if note.tags:
            for tag_name in note.tags:
                tag = get_or_create_tag(db, tag_name)
                db_note.tags.append(tag)
        
        db.add(db_note)
        db.commit()
        db.refresh(db_note)
        
        return db_note
    
    except Exception as e:
        log_error(e, "create_note")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error creating note"
        )


@router.get("/notes/{note_id}", response_model=schemas.Note)
async def get_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Get a specific note by ID"""
    try:
        log_request("GET", f"/notes/{note_id}", user=current_user.username)
        
        note = db.query(models.Note).filter(
            models.Note.id == note_id,
            models.Note.user_id == current_user.id
        ).first()
        
        if not note:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found"
            )
        
        return note
    
    except HTTPException:
        raise
    except Exception as e:
        log_error(e, "get_note")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving note"
        )


@router.put("/notes/{note_id}", response_model=schemas.Note)
async def update_note(
    note_id: int,
    note_update: schemas.NoteUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Update a note
    
    - **title**: optional new title
    - **content**: optional new content
    - **tags**: optional new list of tags (replaces existing tags)
    """
    try:
        log_request("PUT", f"/notes/{note_id}", user=current_user.username)
        
        db_note = db.query(models.Note).filter(
            models.Note.id == note_id,
            models.Note.user_id == current_user.id
        ).first()
        
        if not db_note:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found"
            )
        
        # Update fields
        if note_update.title is not None:
            db_note.title = note_update.title
        if note_update.content is not None:
            db_note.content = note_update.content
        
        # Update tags if provided
        if note_update.tags is not None:
            db_note.tags.clear()
            for tag_name in note_update.tags:
                tag = get_or_create_tag(db, tag_name)
                db_note.tags.append(tag)
        
        db.commit()
        db.refresh(db_note)
        
        return db_note
    
    except HTTPException:
        raise
    except Exception as e:
        log_error(e, "update_note")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error updating note"
        )


@router.delete("/notes/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_note(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Delete a note"""
    try:
        log_request("DELETE", f"/notes/{note_id}", user=current_user.username)
        
        db_note = db.query(models.Note).filter(
            models.Note.id == note_id,
            models.Note.user_id == current_user.id
        ).first()
        
        if not db_note:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found"
            )
        
        db.delete(db_note)
        db.commit()
        
        return None
    
    except HTTPException:
        raise
    except Exception as e:
        log_error(e, "delete_note")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error deleting note"
        )


@router.get("/tags", response_model=List[schemas.Tag])
async def get_tags(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Get all tags used by current user"""
    try:
        log_request("GET", "/tags", user=current_user.username)
        
        # Get all tags from user's notes
        tags = db.query(models.Tag).join(
            models.Note.tags
        ).filter(
            models.Note.user_id == current_user.id
        ).distinct().all()
        
        return tags
    
    except Exception as e:
        log_error(e, "get_tags")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving tags"
        )

