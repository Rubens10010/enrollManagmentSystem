-- Populates 'Test' Database With data from another 'arteycultura_desarrollo'database
-- Only execute after creating database

USE Test;

--TRUNCATE TABLE On_off;
INSERT INTO Test.On_off(Id, Status, Date) SELECT id, onf, fecha FROM arteycultura_desarrollo.on_off;

--TRUNCATE TABLE Subsidiary;
INSERT INTO Test.Subsidiary(IdSubsidiary, SedeName, SedeActive, SedeStatus) SELECT  IdSede, sedeNombre, sedeActivo, sedeEstado FROM arteycultura_desarrollo.sede WHERE SedeEstado = 1;

INSERT INTO Test.College(CollegeName, CollegeStatus) SELECT FacultadNombre, FacultadEstado FROM arteycultura_desarrollo.facultad WHERE FacultadEstado = 1;

-- populate from usuario on arteycultura_desarrollo
INSERT INTO Test.User(IdLevelUser, Username, Firstname, Lastname, Password, UserDNI, Status) SELECT IdTipoUsuario, IdUsuario, UsuarioNombre, UsuarioApellido, UsuarioContrasenia, IdUsuario, UsuarioEstReg FROM arteycultura_desarrollo.usuario;

-- populate users from docente on arteycultura_desarrollo
INSERT INTO Test.User(Username, Firstname, Lastname, Password, UserPhone, UserEmail, UserDNI) SELECT DocenteCodigo, DocenteNombre, DocenteApellido, DocenteCodigo, DocenteCelular, DocenteCorreo, DocenteDNI FROM arteycultura_desarrollo.docente WHERE DocenteEstado = 1;

-- Populate Colleges from this university
INSERT INTO Test.ProfesionalSchool(IdSchool, IdCollege, SchoolName) SELECT IdEscuela, IdFacultad, NombreEscuela FROM arteycultura_desarrollo.escuela WHERE EscuelaEstado = 1;

-- Insert teachers from docente
INSERT INTO Test.Teacher(IdTeacher, IdUser, TeacherDni, TeacherContract, TeacherEmail, TeacherMobile) SELECT D.DocenteCodigo, Tuser.IdUser, D.DocenteDNI, D.DoncenteContra, D.DocenteCorreo, D.DocenteCelular FROM Test.User as Tuser INNER JOIN arteycultura_desarrollo.docente as D on Tuser.Username = D.DocenteCodigo WHERE D.DocenteEstado = 1;

-- Insert location of subsidiaries
INSERT INTO Test.Location(LocationName) SELECT LugarNombre FROM arteycultura_desarrollo.lugar WHERE LugarEstado = 1;

-- Populate periods
INSERT INTO Test.Period(IdPeriod, IdSubsidiary, PeriodYear, PeriodActive, PeriodNumber) SELECT IdPeriodo, IdSede, PeriodoAnio, PeriodoActivo, PeriodoNumero FROM arteycultura_desarrollo.periodo WHERE PeriodoEstado = 1;
--UPDATE TABLE Test.Period SET IdSubsidiary = IdSubsidiary - 6 WHEN IdSubsidiary > 6;

-- Populate existing courses
INSERT INTO Test.Course(IdCourse, CourseName, CourseCredits) SELECT IdCurso, CursoNombre, CursoCreditos FROM arteycultura_desarrollo.curso WHERE CursoEstado = 1;

-- Populate existing workshops
INSERT INTO Test.Workshop(IdWorkshop, IdCourse, IdTeacher, IdPeriod, Capacity, Code, Name, Places, Status)
                            SELECT G.IdGrupo, G.IdCurso, D.DocenteCodigo, G.IdPeriodo, G.GrupoCapacidad, G.GrupoCodigo, G.GrupoNombre, G.places, G.GrupoEstado FROM
                            arteycultura_desarrollo.grupo as G INNER JOIN arteycultura_desarrollo.docente as D ON G.IdDocente = D.IdDocente WHERE D.DocenteEstado = 1 AND
                            G.IdCurso NOT IN (SELECT IdCurso FROM arteycultura_desarrollo.curso WHERE CursoEstado = 0) AND G.IdPeriodo IN (Select IdPeriod FROM Test.Period);

-- Populate Schedule of workshops
INSERT INTO Test.Schedule(IdSchedule, IdWorkshop, IdLocation, Days, StartTime, FinishTime) SELECT IdHorario, IdGrupo, IdLugar, IdDia,  HorarioEntrada, HorarioSalida FROM arteycultura_desarrollo.horario WHERE HorarioEstado = 1 AND IdGrupo IN (SELECT IdWorkshop FROM Test.Workshop) AND IdLugar IN (SELECT IdLocation FROM Test.Location);


-- SELECT * FROM alumno as A1 INNER JOIN alumno as A2 WHERE A1.AlumnoCodigo = A2.AlumnoCodigo AND A1.IdAlumno != A2.IdAlumno GROUP BY A2.AlumnoCodigo;
-- SELECT AlumnoCodigo, COUNT(AlumnoCodigo) FROM alumno GROUP BY AlumnoCodigo HAVING COUNT(AlumnoCodigo) > 1;
-- DELETE t1 FROM alumno t1 INNER JOIN alumno t2 WHERE t1.IdAlumno < t2.IdAlumno AND t1.AlumnoCodigo = t2.AlumnoCodigo;
-- Populate Students in db from alumno

--Insert Into alumnoTemp Select * from alumno group by AlumnoCodigo Desc; // elimina duplicados
INSERT INTO Test.Student(IdStudent, Dni, IdSchool1, IdSchool2, Firstname, Lastname, Email, Cellphone, GuardianName, GuardianPhone, Status) SELECT AlumnoCodigo, AlumnoDni, IdEscuela1, IdEscuela2, AlumnoNombre, AlumnoApellido, AlumnoCorreo, AlumnoCelular, AlumnoPersonaEmergeciaNombre, AlumnoPersonaEmergenciaCelular, AlumnoEstado FROM arteycultura_desarrollo.alumnoTemp;

-- Populate current enrrolled students on StudentWorkshop from alumnogrupo changed Id for CUI
-- Drop those who were enrrolled in a group that doesnt exists anymore
INSERT INTO Test.StudentWorkshop(IdStudentWorkshop, IdWorkshop, IdStudent, DateInscribed, Status) SELECT A.IdAlumnoGrupo, A.IdGrupo, B.AlumnoCodigo, A.fechagrupo, A.AlumnoGrupoEstado FROM arteycultura_desarrollo.alumnogrupo as A INNER JOIN arteycultura_desarrollo.alumno as B on A.IdAlumno = B.IdAlumno and A.IdGrupo in (Select Test.Workshop.IdWorkshop From Test.Workshop);

-- Populate table with Assitances from students
-- This table will be populated day by day
-- INSERT INTO Test.AssistsStudent(IdStudentWorkshop, DateAssist, State)