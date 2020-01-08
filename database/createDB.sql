DROP DATABASE IF EXISTS Test;
CREATE DATABASE Test DEFAULT CHARACTER SET utf8;

Use Test;

CREATE TABLE On_off (
	Id INT NOT NULL AUTO_INCREMENT,
	Status BOOLEAN NOT NULL DEFAULT FALSE,
	Date DATETIME DEFAULT CURRENT_TIME,
	PRIMARY KEY(Id)
);

CREATE TABLE User (
	IdUser INT NOT NULL AUTO_INCREMENT,
	IdLevelUser INT NOT NULL DEFAULT 2,
	UserEmailVerified BOOLEAN DEFAULT FALSE,
	UserRegistrationDate DATETIME DEFAULT CURRENT_TIME,
	UserVerificationCode VARCHAR(20),
	UserIP VARCHAR(20),
	Username VARCHAR(255) NOT NULL,
	Firstname VARCHAR(255) NOT NULL,
	Lastname VARCHAR(255) NOT NULL,
	Password VARCHAR(255) NOT NULL,
	UserCity VARCHAR(255) DEFAULT 'Arequipa',
	UserPhone VARCHAR(255),
	UserAddress VARCHAR(255),
	UserEmail VARCHAR(255) NOT NULL DEFAULT 'dude_opacdr@unsa.edu.pe',
	UserDNI INT NOT NULL,
	Status BOOLEAN DEFAULT FALSE,
	PRIMARY KEY(IdUser)
);

CREATE TABLE College (
	IdCollege INT NOT NULL AUTO_INCREMENT,
	CollegeName VARCHAR(255) NOT NULL,
	CollegeAddress VARCHAR(255) DEFAULT 'UNSA',
	CollegeStatus BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdCollege)
);

CREATE TABLE ProfesionalSchool (
	IdSchool INT NOT NULL AUTO_INCREMENT,
	IdCollege INT NOT NULL,
	SchoolName VARCHAR(255) NOT NULL,
	SchoolContact VARCHAR(255) DEFAULT 'Dirección Universitaria de Admisión Telf. 054 287657',
	SchoolStatus BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdSchool),
	CONSTRAINT fk_IdCollege
	FOREIGN KEY (IdCollege)
	REFERENCES College(IdCollege)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT,
	INDEX idx_schools (IdCollege, IdSchool)
);

CREATE TABLE Teacher (
	IdTeacher INT NOT NULL AUTO_INCREMENT,
	IdUser INT NOT NULL,
	TeacherDni INT NOT NULL,
	TeacherContract VARCHAR(50) NOT NULL,
	TeacherEmail VARCHAR(50) NOT NULL,
	TeacherMobile INT,
	TeacherStatus BOOLEAN DEFAULT TRUE,
	IdDepartment INT,
	PRIMARY KEY(IdTeacher),
	CONSTRAINT fk_IdUser
	FOREIGN KEY (IdUser)
	REFERENCES User(IdUser)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT,
	INDEX idx_teachers (IdTeacher, IdUser, TeacherDni)
);

CREATE TABLE Student (
	IdStudent INT NOT NULL,
	Dni VARCHAR(8) NOT NULL,
	IdSchool1 INT NOT NULL,
	IdSchool2 INT,
	Firstname VARCHAR(255) NOT NULL,
	Lastname VARCHAR(255) NOT NULL,
	Email VARCHAR(255) NOT NULL,
	Cellphone INT,
	Rank TINYINT DEFAULT 1,
	GuardianName VARCHAR(255),
	GuardianPhone VARCHAR(20),
	CoursesTaken TINYINT DEFAULT 0,
	CurrentSemester TINYINT DEFAULT 1,
	Status Boolean DEFAULT TRUE,
	PRIMARY KEY(IdStudent),
	CONSTRAINT fk_IdSchool1
	FOREIGN KEY (IdSchool1)
	REFERENCES ProfesionalSchool(IdSchool)
	ON DELETE RESTRICT
	ON UPDATE RESTRICT,
	INDEX idx_students (IdStudent, IdSchool1, IdSchool2)
);
	
CREATE TABLE Subsidiary (
	IdSubsidiary INT NOT NULL AUTO_INCREMENT,
	SedeName VARCHAR(255) NOT NULL,
	SedeActive BOOLEAN DEFAULT FALSE,
	SedeStatus BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdSubsidiary)
);


CREATE TABLE Period (
	IdPeriod INT NOT NULL AUTO_INCREMENT,
	IdSubsidiary INT NOT NULL,
	PeriodYear YEAR(4) NOT NULL,
	PeriodActive TINYINT DEFAULT FALSE,
	PeriodNumber VARCHAR(11),
	PeriodTotalCapacity INT DEFAULT 0,
	PeriodName VARCHAR(50) DEFAULT 'Talleres Extracurriculares',
	Status BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdPeriod),
	CONSTRAINT fk_IdPeriod
	FOREIGN KEY (IdSubsidiary)
	REFERENCES Subsidiary(IdSubsidiary)
	ON DELETE NO ACTION
    ON UPDATE NO ACTION,
	INDEX idx_periods (IdPeriod, IdSubsidiary)
);

CREATE TABLE Course (
	IdCourse INT NOT NULL AUTO_INCREMENT,
	CourseName VARCHAR(40) NOT NULL,
	CourseDescription VARCHAR(200) DEFAULT 'Curso de los talleres extracurriculares',
	CourseMaxCapacity TINYINT DEFAULT 100,
	CourseCredits TINYINT DEFAULT 5,
	CourseImgPath VARCHAR(255),
	Status BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdCourse)
);

-- CONSTRAINT fk_IdSchedule FOREIGN KEY(IdSchedule) REFERENCES Schedule(IdSchedule) ON UPDATE RESTRICT ON DELETE RESTRICT,
-- IdSchedule INT NOT NULL,
CREATE TABLE Workshop (
	IdWorkshop INT NOT NULL AUTO_INCREMENT,
	IdCourse INT NOT NULL,
	IdTeacher INT NOT NULL,
	IdPeriod INT NOT NULL,
	-- StartDate DATETIME NOT NULL DEFAULT CURRENT_DATE,
	DaysDuration INT NOT NULL DEFAULT 16,
	Capacity TINYINT NOT NULL DEFAULT 100,
	Places TINYINT NOT NULL DEFAULT 100,
	Enrolled TINYINT NOT NULL DEFAULT 0,
	Name VARCHAR(255),
	Code VARCHAR(20),
	Available BOOLEAN DEFAULT TRUE,
	Finished BOOLEAN DEFAULT FALSE,
	Status BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdWorkshop),
	CONSTRAINT fk_workshopIdCourse FOREIGN KEY(IdCourse) REFERENCES Course(IdCourse) ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT fk_workshopIdTeacher FOREIGN KEY(IdTeacher) REFERENCES Teacher(IdTeacher) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_workshopIdPeriod FOREIGN KEY(IdPeriod) REFERENCES Period(IdPeriod) ON UPDATE RESTRICT ON DELETE RESTRICT,
    INDEX idx_workshops (IdPeriod, IdCourse, IdWorkshop),
    INDEX idx_places (Capacity, Places, Enrolled)
);

CREATE TABLE Location (
	IdLocation INT NOT NULL AUTO_INCREMENT,
	LocationName VARCHAR(255) NOT NULL,
	LocationAddress VARCHAR(255) DEFAULT 'UNSA',
	Status BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdLocation)
);

CREATE TABLE Schedule (
	IdSchedule INT NOT NULL AUTO_INCREMENT,
	IdWorkshop INT NOT NULL,
	IdLocation INT NOT NULL,
	Days INT DEFAULT 123456,
	StartTime DATETIME NOT NULL,
	FinishTime DATETIME NOT NULL,
	Status BOOLEAN DEFAULT TRUE,
	PRIMARY KEY(IdSchedule),
	CONSTRAINT fk_IdWorkshop
	FOREIGN KEY(IdWorkshop) REFERENCES Workshop(IdWorkshop)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
	CONSTRAINT fk_IdLocation
	FOREIGN KEY(IdLocation) REFERENCES Location(IdLocation)
	ON UPDATE RESTRICT ON DELETE RESTRICT,
	INDEX idx_schedules (IdWorkshop, IdSchedule)
);

-- tabla que identifica un estudiante en un grupo taller
CREATE TABLE StudentWorkshop (
    IdStudentWorkshop INT NOT NULL AUTO_INCREMENT,
    IdWorkshop INT NOT NULL,
    IdStudent INT NOT NULL,
    StudentCondition TINYINT NOT NULL DEFAULT 1,  -- ABANDONO, APROBADO, DESAPROBADO
    DateInscribed DATETIME DEFAULT CURRENT_TIME,
    NumOfAbsences TINYINT DEFAULT 0,
    Status BOOLEAN DEFAULT TRUE,
    PRIMARY KEY(IdStudentWorkshop),
    CONSTRAINT fk_StudentWorkshop_Workshop
    FOREIGN KEY (IdWorkshop) REFERENCES Workshop(IdWorkshop)
    ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT fk_StudentWorkshop_Student
    FOREIGN KEY (IdStudent) REFERENCES Student(IdStudent)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE AssistsStudent (
    IdAssistsRecord INT NOT NULL AUTO_INCREMENT,
    IdStudentWorkshop INT NOT NULL,
    DateAssist DATETIME NOT NULL DEFAULT CURRENT_DATE,
    Outcome BOOLEAN DEFAULT FALSE,   -- 0 no vino 1 vino
    Status BOOLEAN DEFAULT TRUE,
    PRIMARY KEY(IdAssistsRecord),
    CONSTRAINT fk_StudentWorkshop
    FOREIGN KEY (IdStudentWorkshop) REFERENCES StudentWorkshop(IdStudentWorkshop)
    ON UPDATE RESTRICT ON DELETE RESTRICT
);