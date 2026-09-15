-- ============================================================
-- BASELINE: dbo.vw_usuarios_app
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_usuarios_app]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_usuarios_app] as

select  
	 cli_cd_codigo_cliente	AS CodTransportadora
 	,usr_cd_usuario			AS CodUsuario
	,usr_nm_usuario			AS NomeUsuario
	,usr_ds_num_telefone	AS Telefone

from tb_usuario NOLOCK
where usr_in_ativo = 1
and usr_ds_num_telefone is not null


--select top 10 *  from  vw_usuarios_app
GO
