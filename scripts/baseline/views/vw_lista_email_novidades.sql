-- ============================================================
-- BASELINE: dbo.vw_lista_email_novidades
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lista_email_novidades]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_lista_email_novidades]

as
select *
from (
select usr_ds_email as Email,  --Não inverter a ordem
	   users.usr_nm_usuario as Usuario,
	   clientes.cli_ds_nome as Cliente,
	   SUBSTRING(usr_ds_email, CHARINDEX('@',usr_ds_email)+1,CHARINDEX('.',usr_ds_email,CHARINDEX('@',usr_ds_email)) - CHARINDEX('@',usr_ds_email) -1) AS DominioEmail
from tb_usuario as users
	join tb_clientes as clientes on users.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
	inner join (select distinct uga_cd_usuario from tb_usuario_grupo_acesso) as usuarios_acesso on users.usr_cd_usuario = usuarios_acesso.uga_cd_usuario
	left join (select distinct NomeMotorista from tb_ml_rotas) as motoristasMeli on users.usr_nm_usuario = motoristasMeli.NomeMotorista
	left join (select distinct NomeMotorista from tb_spe_motoristas_novo) as motoristasshopee on users.usr_nm_usuario = motoristasshopee.NomeMotorista
	left join (select distinct uga_cd_usuario from tb_usuario_grupo_acesso where uga_cd_grupo_acesso = 20) as usuarios_grupo_motorista on users.usr_cd_usuario = usuarios_grupo_motorista.uga_cd_usuario
where users.usr_in_ativo = 1
	  and clientes.cli_in_ativo = 1
	  and motoristasMeli.NomeMotorista is null
	  and motoristasshopee.NomeMotorista is null
	  and isnull(users.usr_in_motorista,0) <> 1
	  and usr_ds_email like '%@%'
	  and usuarios_grupo_motorista.uga_cd_usuario is null
	 ) as base
where DominioEmail not in (
	'89gmail'
	,'default'
	,'email'
	,'GAMIL'
	,'gmai'
	,'gmaill'
	,'gmal'
	,'gmaol'
	,'gmi'
	,'gs'
	,'homail'
	,'hormail'
	,'HOTIMAIL'
	,'HOTNAIL'
	,'NOME'
	,'outllok'
	,'outllook'
	,'possui'
	,'testeapp'
	,'VANDER'
	,'vitoriapizzas'
	,'YHAOO'
)

and Email not in

(
'ALIICE_HANDMADE@OUTLOOK.COM'
,'alessandrafl@fcargo.com.br'
,'andreguaruja@hotmail.com'
,'ap.santiago@yahoo.com.br'
,'assenldc@gmail.com'
,'Cammitransportes@outlook.com'
,'cristiane.tp@hotmail.com'
,'CYNTHIA_RUBIN@HOTMAIL.COM'
,'diasvaleria2019@gmail.com'
,'dihduarte13@gmail.com'
,'elizeudsoulsa@gmail.com'
,'ELIZEUSOUL@GMAIL.COM'
,'FELIPECESTARI@LIVE.COM'
,'FILIPE.LUIS0905@GMAIL.COM'
,'FNDALVESBATISTA@OUTLOOK.COM'
,'gabriel.daviluccaaa@gmail.com'
,'geanferreira0@gmail.com'
,'GISELLIGOMESMOURA@GMAIL.COM'
,'graziellesdias@hotmail.com'
,'iaraalicemartins@gmail.com'
,'karolvictorpavei@gmail.com'
,'KELICAIADO@HOTMAIL.COM'
,'LETICIA_RONALDINHO@HOTMAIL.COM'
,'LUIZFERNANDODACRUZLIBANIO@GMAIL.COM'
,'luizLopeslpo@gmail.com'
,'marcio.rochag@hotmail.com'
,'mobbyentregas@gmail.com'
,'moisesneguin@outlook.com'
,'nadiarosadaveiga@hotmail.com'
,'operacionalmao@50maiscs.com.br'
,'PEROBELLILECASOUZA@GMAIL.COM'
,'ricardobreno679@gmail.com'
,'ronaldomatos6061@gmail.com'
,'RUEDIGER.OTAVIO14@HOTMAIL.COM'
)


GO
