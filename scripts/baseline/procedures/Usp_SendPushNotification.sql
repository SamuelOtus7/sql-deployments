-- ============================================================
-- BASELINE: dbo.Usp_SendPushNotification
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_SendPushNotification]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_SendPushNotification]
(
	@CodigoUsuario int,
	@Titulo varchar(100),
	@Mensagem varchar (250)
)

as

begin

	Declare @Object as Int;
	Declare @ResponseText as Varchar(8000);
	Declare @Body as varchar(8000) = 
	'{
	 "cod_usuario": ' + cast(@CodigoUsuario as varchar(10)) + ',
	 "titulo": "' + @Titulo + '",
	 "texto": "' + @Mensagem + '",
	 "key": "zP5WR0siZdx8tzJ4dklhblcQU4WBL0VXuZazELkJUx0="
	}' 

	Exec sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
	EXEC  sp_OAMethod @Object, 'open', NULL, 'post','https://driveanalytics.athene7.com/api/sistema/pushnotification', 'false'

	Exec sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	Exec sp_OAMethod @Object, 'send', null, @body

	Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
	Select @ResponseText

	Exec sp_OADestroy @Object

end
GO
