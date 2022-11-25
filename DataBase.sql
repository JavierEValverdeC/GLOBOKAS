/*************************
*
* Desarrollador : Javier Enmanuel Valverde Ccasihui
* Correo: javiervalverde.sistemas@gmail.com
* Fecha: 24/11/2022
*
* ¡PRESIONAR F5!
*
*************************/
CREATE DATABASE DB_NetPromoterScore_V1;
GO
USE DB_NetPromoterScore_V1;
GO

/*************************
*
* Creación de Tablas
*
*************************/
IF OBJECT_ID('TB_PERSON', 'U') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP TABLE TB_PERSON
GO
CREATE TABLE TB_PERSON
(
IdPerson								INT				IDENTITY(1,1),
DocumentNumber							VARCHAR(50)		NOT NULL,
PersonName								VARCHAR(150)	NOT NULL,
FirstLastName							VARCHAR(150)	NOT NULL,
SecondLastName							VARCHAR(150)	NOT NULL,
RegistrationStatus						CHAR(1)			NOT NULL		DEFAULT 'A',
RegistrationUser						INT				NOT NULL,
RegistrationDate						DATETIME		NOT NULL		DEFAULT GETDATE(),
UpdateUser								INT				NOT NULL		,
UpdateDate								DATETIME		NOT NULL		DEFAULT GETDATE()
CONSTRAINT PK_Person					PRIMARY KEY		(IdPerson))
GO

IF OBJECT_ID('TB_PROFILE', 'U') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP TABLE TB_PROFILE
GO
CREATE TABLE TB_PROFILE
(
IdProfile								INT				IDENTITY(1,1),
ProfileName								VARCHAR(100)	NOT NULL,
RegistrationStatus						CHAR(1)			NOT NULL		DEFAULT 'A',
RegistrationUser						INT				NOT NULL,
RegistrationDate						DATETIME		NOT NULL		DEFAULT GETDATE(),
UpdateUser								INT				NOT NULL		,
UpdateDate								DATETIME		NOT NULL		DEFAULT GETDATE()
CONSTRAINT PK_Profile					PRIMARY KEY		(IdProfile))
GO

IF OBJECT_ID('TB_USER', 'U') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP TABLE TB_USER
GO
CREATE TABLE TB_USER
(
IdUser									INT				IDENTITY(1,1),
IdPerson								INT				NOT NULL,
IdProfile								INT				NOT NULL,
UUser									VARCHAR(100)	NOT NULL,
UPassword								VARCHAR(100)	NOT NULL,
RegistrationStatus						CHAR(1)			NOT NULL		DEFAULT 'A',
RegistrationUser						INT				NOT NULL,
RegistrationDate						DATETIME		NOT NULL		DEFAULT GETDATE(),
UpdateUser								INT				NOT NULL		,
UpdateDate								DATETIME		NOT NULL		DEFAULT GETDATE()
CONSTRAINT FK_User_Person				FOREIGN KEY		(IdPerson)		REFERENCES TB_PERSON (IdPerson),
CONSTRAINT FK_User_Profile				FOREIGN KEY		(IdProfile)		REFERENCES TB_PROFILE (IdProfile),
CONSTRAINT PK_User						PRIMARY KEY		(IdUser))
GO

IF OBJECT_ID('TB_PARAMETER', 'U') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP TABLE TB_PARAMETER
GO
CREATE TABLE TB_PARAMETER
(
IdParameter								INT				IDENTITY(1,1),
ParamDescription						VARCHAR(255)	NOT NULL,
ParamKey								VARCHAR(100)	NOT NULL,
ParamValue								VARCHAR(100)	NOT NULL,
RegistrationStatus						CHAR(1)			NOT NULL		DEFAULT 'A',
RegistrationUser						INT				NOT NULL,
RegistrationDate						DATETIME		NOT NULL		DEFAULT GETDATE(),
UpdateUser								INT				NOT NULL		,
UpdateDate								DATETIME		NOT NULL		DEFAULT GETDATE()
CONSTRAINT PK_Parameter					PRIMARY KEY		(IdParameter))
GO

IF OBJECT_ID('TB_USER_RESPONSE', 'U') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP TABLE TB_USER_RESPONSE
GO
CREATE TABLE TB_USER_RESPONSE
(
IdUserResponse							INT				IDENTITY(1,1),
IdUser									INT				NOT NULL,
IdQuestion								INT				NOT NULL,
Score									INT				NOT NULL,
RegistrationStatus						CHAR(1)			NOT NULL		DEFAULT 'A',
RegistrationUser						INT				NOT NULL,
RegistrationDate						DATETIME		NOT NULL		DEFAULT GETDATE(),
UpdateUser								INT				NOT NULL		,
UpdateDate								DATETIME		NOT NULL		DEFAULT GETDATE()
CONSTRAINT FK_UserResponse_User			FOREIGN KEY		(IdUser)		REFERENCES TB_USER (IdUser),
CONSTRAINT FK_UserResponse_Parameter	FOREIGN KEY		(IdQuestion)	REFERENCES TB_PARAMETER (IdParameter),
CONSTRAINT PK_UserResponse				PRIMARY KEY		(IdUserResponse))
GO

/*************************
*
* INSERT TABLES
*
*************************/
INSERT INTO TB_PERSON (DocumentNumber, PersonName, FirstLastName, SecondLastName, RegistrationUser, UpdateUser) 
VALUES ('12345678','JAVIER', 'VALVERDE', 'CCASIHUI', 1, 1)
INSERT INTO TB_PERSON (DocumentNumber, PersonName, FirstLastName, SecondLastName, RegistrationUser, UpdateUser) 
VALUES ('12345678','JHONNY', 'GUEVARA', 'DIAZ', 1, 1)

INSERT INTO TB_PROFILE (ProfileName, RegistrationUser, UpdateUser) 
VALUES ('ADMINISTRADOR', 1,1)
INSERT INTO TB_PROFILE (ProfileName, RegistrationUser, UpdateUser) 
VALUES ('VOTANTE', 1,1)

INSERT INTO TB_USER (IdPerson, IdProfile, UUser, UPassword, RegistrationUser, UpdateUser) 
VALUES (1, 1,'JVALVERDE', 'VALVERDE',1,1)
INSERT INTO TB_USER (IdPerson, IdProfile, UUser, UPassword, RegistrationUser, UpdateUser) 
VALUES (2, 2,'JGUEVARA', 'GUEVARA',1,1)

INSERT INTO TB_PARAMETER(ParamDescription, ParamKey, ParamValue, RegistrationUser, UpdateUser)
VALUES ('¿Cuán probable es que recomiende el producto o servicio a un familiar o amigo?','NPS_PREGUNTA','1',1,1)

INSERT INTO TB_USER_RESPONSE(IdUser, IdQuestion, Score, RegistrationUser, UpdateUser)
VALUES(2,1,10,1,1)

GO

/*************************
*
* Creación de Stored Procedures
*
*************************/
IF OBJECT_ID('LSP_USER_RESPONSE_LIST', 'P') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP PROCEDURE LSP_USER_RESPONSE_LIST
GO
CREATE PROCEDURE LSP_USER_RESPONSE_LIST --2
------------------------------------------------------------------------------      
-- Autor   : Javier Enmanuel Valverde Ccasihui  
-- Fecha creación : 24/11/2022      
-- Descripción  : Reporte de las respuestas de Net Promoter Score.
------------------------------------------------------------------------------      
-- Parámetros de Entrada   
-- @IdUser	INT: Id del usuario.
------------------------------------------------------------------------------    
-- Modificado por  : 
-- Motivo:       
-- Fecha Modificación :       
-- Version     : 1.0.0     
------------------------------------------------------------------------------  
@IdUser INT
AS
BEGIN
	IF((SELECT COUNT('X') FROM TB_USER u INNER JOIN TB_PROFILE p ON u.IdProfile = p.IdProfile WHERE u.IdUser = @IdUser AND p.ProfileName = 'ADMINISTRADOR') > 0)
		BEGIN
			SELECT 
				IdUserResponse,	
				U.IdUser,			
				IdQuestion,		
				Score,
				P.PersonName,
				P.FirstLastName,
				P.SecondLastName,
				'1' AS ValorConsulta
			FROM
			TB_USER_RESPONSE UR 
			INNER JOIN TB_USER U
			ON UR.IdUser = U.IdUser
			INNER JOIN TB_PERSON P
			ON P.IdPerson = U.IdPerson

		END
	ELSE
		BEGIN
				SELECT 
				0 AS IdUserResponse,	
				0 AS IdUser,			
				0 AS IdQuestion,		
				0 AS Score,
				'' AS PersonName,
				'' AS FirstLastName,
				'' AS SecondLastName,
				'USUARIO NO TIENE PERFIL DE ADMINISTRADOR.' AS ValorConsulta
		END
END
GO

IF OBJECT_ID('MSP_USER_RESPONSE_CREATE', 'P') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP PROCEDURE MSP_USER_RESPONSE_CREATE
GO
CREATE PROCEDURE MSP_USER_RESPONSE_CREATE --
----------------------------------------------------------------------------------------------      
-- Autor   : Javier Enmanuel Valverde Ccasihui  
-- Fecha creación : 24/11/2022      
-- Descripción  : Registrar las respuestas de Net Promoter Score.
----------------------------------------------------------------------------------------------       
-- Parámetros de Entrada   
-- @IdUser		INT: Código de usuario.
-- @Score		INT: Calificación de la encuesta Net Promoter Score.
----------------------------------------------------------------------------------------------     
-- Modificado por  : 
-- Motivo:       
-- Fecha Modificación :       
-- Version     : 1.0.0  
---------------------------------------------------------------------------------------------- 
@IdUser		INT,
@Score		INT
AS
DECLARE @Result VARCHAR(500), @Mensaje VARCHAR(500),@IdQuestion INT
SET	@Result='0'
SET @Mensaje = ''
BEGIN
	BEGIN TRANSACTION
		BEGIN  TRY
			
			IF(@Score < 0 OR  @Score > 10)
				BEGIN
					SET @Mensaje='LA PUNTUACIÓN DEBE ESTAR EN EL RANGO DEL 0 AL 10.'
				END
			ELSE IF((SELECT COUNT('X') FROM TB_USER u INNER JOIN TB_PROFILE p ON u.IdProfile = p.IdProfile WHERE u.IdUser = @IdUser AND p.ProfileName = 'VOTANTE') = 0)
				BEGIN
					SET @Mensaje='EL USUARIO NO TIENE EL PERFIL DE VOTANTE.'
				END
			ELSE IF((SELECT COUNT('X') FROM TB_USER_RESPONSE WHERE IdUser = @IdUser) > 0)
				BEGIN
					SET @Mensaje = 'EL USUARIO YA HA REGISTRADO SU CALIFICACIÓN.'
				END
			ELSE
				BEGIN
					SET @IdQuestion = (SELECT TOP 1 IdParameter FROM TB_PARAMETER WHERE ParamKey='NPS_PREGUNTA' AND ParamValue='1')

					INSERT INTO TB_USER_RESPONSE(IdUser, IdQuestion, Score, RegistrationUser, UpdateUser)
					VALUES(@IdUser,@IdQuestion,@Score,@IdUser,@IdUser)
					SET	@Result='1'
					SET @Mensaje = 'CALIFICACIÓN REGISTRADO CON ÉXITO.'
				END

		END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Mensaje=SUBSTRING(ERROR_MESSAGE(),1,300)
	END CATCH
	IF @@TRANCOUNT>0
		BEGIN
			COMMIT TRANSACTION
		END
	SELECT @Result AS 'ValorConsulta', @Mensaje AS 'MensajeConsulta' 
END
GO


IF OBJECT_ID('USP_USER_RESPONSE_RESULT', 'P') IS NOT NULL  -- Si la tabla <nombre_tabla> existe...
  DROP PROCEDURE USP_USER_RESPONSE_RESULT
GO
CREATE PROCEDURE USP_USER_RESPONSE_RESULT --2
------------------------------------------------------------------------------      
-- Autor   : Javier Enmanuel Valverde Ccasihui  
-- Fecha creación : 24/11/2022      
-- Descripción  : Obtener resultado de las respuestas de Net Promoter Score.
------------------------------------------------------------------------------      
-- Parámetros de Entrada   
-- @IdUser	INT: Id del usuario.
------------------------------------------------------------------------------    
-- Modificado por  : 
-- Motivo:       
-- Fecha Modificación :       
-- Version     : 1.0.0     
------------------------------------------------------------------------------  
@IdUser INT
AS
DECLARE @TotalPromotores FLOAT, @TotalDetractores FLOAT, @TotalEncuestados FLOAT, @Resultado FLOAT, @Mensaje VARCHAR(100)
SET @Resultado = 0
SET @Mensaje = ''
BEGIN
	IF((SELECT COUNT('X') FROM TB_USER u INNER JOIN TB_PROFILE p ON u.IdProfile = p.IdProfile WHERE u.IdUser = @IdUser AND p.ProfileName = 'ADMINISTRADOR') > 0)
		BEGIN
			SET @TotalEncuestados = (SELECT COUNT('X') FROM TB_USER_RESPONSE)
			IF(@TotalEncuestados > 0)
				BEGIN
					SET @TotalPromotores = (SELECT COUNT('X') FROM TB_USER_RESPONSE WHERE Score > 8)
					SET @TotalDetractores = (SELECT COUNT('X') FROM TB_USER_RESPONSE WHERE Score < 7)
					SET @Resultado = ((@TotalPromotores - @TotalDetractores) / @TotalEncuestados ) * 100
				END
			ELSE
				BEGIN
					SET @Mensaje = 'NO EXISTE REGISTROS.'
					SET @Resultado  = 0
				END
		END
	ELSE
		BEGIN
			SET @Mensaje = 'SOLO LOS USUARIOS CON PERFIL DE ADMINISTRADOR PUEDEN OBSERVAR LOS RESULTADOS NPS.'
			SET @Resultado  = 0
		END
	
	SELECT @Mensaje AS 'MensajeConsulta',@Resultado AS 'ValorConsulta'
END
GO