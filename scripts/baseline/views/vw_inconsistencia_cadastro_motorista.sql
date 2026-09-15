-- ============================================================
-- BASELINE: dbo.vw_inconsistencia_cadastro_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_inconsistencia_cadastro_motorista]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_inconsistencia_cadastro_motorista]
as

select 
	UltimoApontamento,
	TenantId,
	usr_nm_usuario as Nome,
	usr_ds_email as Email,
	--ml.NomeMotorista,
	--ml_email.Email,
	case 
		when ml.NomeMotorista is null  and  ml_email.Email is null then 'Nome e Email Inconsistentes'
		when ml.NomeMotorista is null then 'Nome Inconsistente' 
		when ml_email.Email is null then 'Email Inconsistente' 
		end Inconsistencia
		
from
	(
	select 
			b.usr_nm_usuario
			,b.usr_cd_driverid
		, c.cli_id_logistics
		, c.cli_ds_nome
		, b.usr_ds_email 
		, max(rgp_dh_data_hora) as UltimoApontamento
		, c.cli_cd_codigo_cliente TenantId

	from tb_registro_gps a	
		join tb_usuario b on a.rgp_cd_usuario = b.usr_cd_usuario
		join tb_clientes c on b.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
	where a.rgp_dh_data_hora >= '2023-11-01'
	and c.cli_cd_codigo_cliente <> 7
	group by 
		--b.usr_nm_usuario, cli_id_logistics, c.cli_ds_nome, b.usr_ds_email,c.cli_cd_codigo_cliente
		b.usr_nm_usuario,b.usr_cd_driverid, cli_id_logistics, c.cli_ds_nome, b.usr_ds_email,c.cli_cd_codigo_cliente

	) as base

left join 
	(
	select distinct
	IdTransportadora
	,Nome as NomeMotorista
	,IdMotorista 
	from [dbo].[tb_ml_motoristas]

	) as ml
on  base.cli_id_logistics = ml.IdTransportadora 
--and base.usr_nm_usuario   = ml.NomeMotorista
and base.usr_cd_driverid   = ml.IdMotorista


left join 
	(
		select 
		 IdTransportadora
		,Email

		from [dbo].[tb_ml_motoristas]

	) as ml_email
on  base.cli_id_logistics = ml_email.IdTransportadora 
and base.usr_ds_email   = ml_email.Email


where 
	(ml.IdTransportadora is null
	or ml_email.IdTransportadora is null)
--and cli_ds_nome = 'ALC Transportes'




GO
