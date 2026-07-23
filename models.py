# backend/app/models.py
import uuid
from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, Enum, ForeignKey, Time, Computed, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from database import Base 
from datetime import date
from sqlalchemy.orm import relationship
import enum

class Client(Base):
    __tablename__ = "clients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    region = Column(String(100), nullable=True)
    default_currency = Column(String(3), default="BRL")
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    projects = relationship("Project", backref="client")

class UserRole(str, enum.Enum):
    USER = "user"
    MANAGER = "manager"
    ADMIN = "admin"
    ADMINISTRATOR = "ADMINISTRATOR"
    HEAD = "HEAD"

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    auth_provider = Column(String, nullable=True)
    entra_object_id = Column(String, nullable=True)
    password_hash = Column(String, nullable=False)
    role = Column(Enum(UserRole), default=UserRole.USER)
    
    client_id = Column(UUID(as_uuid=True), nullable=True)
    calendar_id = Column(UUID(as_uuid=True), nullable=True)
    weekly_capacity_hours = Column(Numeric(5, 2), nullable=True)
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

class Project(Base):
    __tablename__ = "projects"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    model = Column(Enum("WATERFALL", "AGILE", "HYBRID", name="project_model"), nullable=False, default="WATERFALL")
    allocation_mode = Column(Enum("SQUAD", "DIRECT", name="allocation_mode"), nullable=False, default="SQUAD")
    
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id"), nullable=True)
    calendar_id = Column(UUID(as_uuid=True), nullable=True)
    manager_user_id = Column(UUID(as_uuid=True), nullable=True)
    
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String, nullable=False, default="DRAFT")
    
    start_date = Column(Date, nullable=False, default=date.today)
    end_date = Column(Date, nullable=True)
    
    currency = Column(String(3), default="BRL")
    estimated_cost = Column(Numeric, nullable=True)
    estimated_revenue = Column(Numeric, nullable=True)
    
    hubspot_deal_id = Column(String, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    tasks = relationship("Task", backref="project")
    members = relationship("ProjectMember", backref="project", cascade="all, delete-orphan")
    milestones = relationship("Milestone", backref="project", cascade="all, delete-orphan")

class ProjectMember(Base):
    __tablename__ = "project_members"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Milestone(Base):
    __tablename__ = "milestones"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    target_date = Column(Date, nullable=False)
    status = Column(String, default="PENDING")
    approved_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    approved_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Task(Base):
    __tablename__ = "tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    
    sprint_id = Column(UUID(as_uuid=True), nullable=True)
    milestone_id = Column(UUID(as_uuid=True), ForeignKey("milestones.id"), nullable=True)
    parent_task_id = Column(UUID(as_uuid=True), nullable=True)
    assigned_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    status = Column(String, default="TODO") 
    priority = Column(String, default="MEDIUM")
    
    billable = Column(
        Enum("BILLABLE", "NON_BILLABLE", name="billable_type", create_type=False), 
        default="BILLABLE"
    )
    
    story_points = Column(Integer, nullable=True)
    estimated_effort_hours = Column(Integer, nullable=False)
    manual_progress = Column(Integer, nullable=True)  # Adicionado progresso manual
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    due_date = Column(Date, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    timelogs = relationship("TimeLog", backref="task")
    comments = relationship("TaskComment", backref="task", cascade="all, delete-orphan")

class TaskComment(Base):
    __tablename__ = "task_comments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    author_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    comment = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

class TaskDependency(Base):
    __tablename__ = "task_dependencies"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    successor_task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    predecessor_task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class TimeLog(Base):
    __tablename__ = "time_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    logged_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=True)
    end_time = Column(Time, nullable=True)
    
    hours_spent = Column(Numeric(10, 2), Computed("end_time - start_time", persisted=True))
    
    billable = Column(Enum("BILLABLE", "NON_BILLABLE", name="billable_type", create_type=False), default="BILLABLE")
    
    entry_type = Column(Enum("REGULAR", "ADDITIONAL", "OVERTIME", name="timelog_entry_type", create_type=False), default="REGULAR")
    
    approval_status = Column(Enum("PENDING", "APPROVED", "REJECTED", name="approval_status_enum", create_type=False), default="PENDING")
        
    approved_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    approved_at = Column(DateTime(timezone=True), nullable=True)
    rejection_reason = Column(Text, nullable=True)
    revision_note = Column(Text, nullable=True)
    payment_release_id = Column(UUID(as_uuid=True), nullable=True)
    description = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)