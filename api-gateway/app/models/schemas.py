# api-gateway/app/models/schemas.py
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    disabled: Optional[bool] = None

    class Config:
        from_attributes = True

class UserInDB(User):
    hashed_password: str

class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None

class ProjectCreate(ProjectBase):
    pass

class Project(ProjectBase):
    path: str
    created_at: datetime

    class Config:
        from_attributes = True

class Extension(BaseModel):
    id: str
    name: str
    version: str
    publisher: str
    description: Optional[str] = None

class TerminalSession(BaseModel):
    id: str
    shell: str
    created_at: datetime
    active: bool

class CommandRequest(BaseModel):
    command: str
    args: Optional[list] = None
    cwd: Optional[str] = None