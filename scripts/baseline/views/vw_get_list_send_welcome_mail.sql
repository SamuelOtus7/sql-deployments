-- ============================================================
-- BASELINE: dbo.vw_get_list_send_welcome_mail
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_get_list_send_welcome_mail]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_get_list_send_welcome_mail]  
as  

select distinct usr_ds_email 
from tb_usuario as users
	join tb_clientes as clientes on users.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
	left join (select distinct nomemotorista,IdTransportadora from tb_ml_rotas where DataReferencia >= dateadd(day,-15,cast(getdate() as date))) as meli
	on users.usr_nm_usuario = meli.NomeMotorista and clientes.cli_id_logistics = meli.IdTransportadora
	left join (select distinct Motorista,IdTransportadora from tb_spe_rotas_v5 where DataReferencia >= dateadd(day,-15,cast(getdate() as date))) as shopee
	on users.usr_nm_usuario = shopee.Motorista and clientes.cli_id_shopee = shopee.IdTransportadora
where isnull(usr_in_motorista,0) = 1
	  and usr_in_ativo = 1
	  and usr_cd_usuario not in (select distinct usr_cd_usuario from tb_logs_acessos where log_dh_acesso >= dateadd(day,-7,cast(getdate() as date)))
	  and clientes.cli_ds_nome in ('MSR Transportes')
	  --and usr_ds_email not like '%_inativo%'
	  --and usr_ds_email not like '%_deletado%'
	  and (meli.IdTransportadora is not null or shopee.IdTransportadora is not null)
GO
