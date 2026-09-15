-- ============================================================
-- BASELINE: dbo.vw_usuarios_periodo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_usuarios_periodo]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_usuarios_periodo] as 

select 
	mtn_cd_pgto_periodo as CodPeriodo
	,pgp_nm_periodo as NomePeriodo
	,b.mot_ds_plate as Placa
	,b.mot_ds_vehicle_type as TipoVeiculo
	,b.mot_cd_usuario as CodUsuario
	,b.mot_cpf as CPF
	,b.mot_cnt_vl_email as Email
	,b.mot_nm_svc as Base
	,b.mot_nm_motorista as NomeMotorista
	,b.mot_cd_status as Status
	,case 
		when b.mot_cd_status = 1 then 'Ativo' 
		when b.mot_cd_status = 2 then 'Inativo' 
		when b.mot_cd_usuario is null then 'Inativo' 
		else 'Sem cadastro' end as SituacaoCadastral
	,b.mot_cd_cliente as tenant
	,mot_pag_nm_empresa as MktPlace

from tb_pag_espelhos as a
inner join 
(
	select 
		 mot_ds_plate
		,mot_ds_vehicle_type
		,mot_cd_usuario
		,mot_cpf
		,mot_cnt_vl_email
		,mot_nm_svc
		,mot_nm_motorista
		,mot_cd_status
		,mot_cd_cliente
		,mot_pag_nm_empresa

	from tb_motorista
	-- where mot_cd_cliente = 27
	-- and mot_cd_status = 1
) as b
on a.mtn_cd_motorista = b.mot_cd_usuario

left join tb_pgto_periodo as c
on a.mtn_cd_pgto_periodo = c.pgp_cd_periodo

-- where a.mtn_cd_pgto_periodo = 592
GO
