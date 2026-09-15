-- ============================================================
-- BASELINE: dbo.vw_dados_motoristas_ml
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_motoristas_ml]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_dados_motoristas_ml] as 

SELECT 
	IdMotorista	
	, usr_cd_usuario as idDA
	,b.cli_cd_codigo_cliente IdTransportadora	
	,a.IdTransportadora as IdTransportadorafiltro
	,CPF	
	,Nome	
	,case when usr_in_ativo = 1 or Ativo is null then 'Ativo' else 'Inativo' end Ativo
	,Email	
	,Telefone	
	,IdSite
	,usr_ds_base as svc

FROM [dbo].[tb_ml_motoristas] as a with(nolock)

inner join tb_clientes as b
on a.IdTransportadora = b.cli_id_logistics
 and cli_in_ativo = 1

left join [dbo].[tb_usuario] as usu with(nolock)
on usu.usr_ds_email = a.Email
and b.cli_cd_codigo_cliente = usu.cli_cd_codigo_cliente

where 1=1
and b.cli_cd_codigo_cliente <> 7

GO
