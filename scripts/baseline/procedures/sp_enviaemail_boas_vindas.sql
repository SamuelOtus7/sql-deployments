-- ============================================================
-- BASELINE: dbo.sp_enviaemail_boas_vindas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_enviaemail_boas_vindas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_enviaemail_boas_vindas]
(
	@email varchar(150),
	@senha varchar(50) = null
)

as

begin 

	declare @nome varchar(100) ,
			@msg varchar(1000),
			@url varchar(100) = 'https://driveanalytics.athene7.com'
	
	select @nome = usr_nm_usuario from tb_usuario where usr_ds_email = @email

	set @msg ='
	Prezado ' + @nome + ', <br> 
	Seja bem-vindo ao app Drive Analytcs, uma plataforma completa que lhe auxiliará na gestão logística.<br>
	Acesso o endereço <a href="' + @url + '">' + replace(@url,'https://','') + '</a> com as credenciais abaixo: <br>
	Usuário: ' + @email + '<br>
	Senha:' + @senha + '<br>'
	--Faça o download do aplicativo na <a href="https://apps.apple.com/br/app/simgular/id1532898142">App Store</a> ou <a href="https://play.google.com/store/apps/details?id=com.otus.simgular&hl=pt_BR&gl=US">Google Play</a>.'


	exec sp_sendmail_portal
		@title = 'Bem-vindo ao Drive Analytcs',
		@mensagem = @msg,
		@importante = 'Normal',
		@destinatarios = @email,
		@copia_oculta = 1,
		@anexo = null

end



GO
