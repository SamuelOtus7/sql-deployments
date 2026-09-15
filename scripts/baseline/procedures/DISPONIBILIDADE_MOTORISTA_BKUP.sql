-- ============================================================
-- BASELINE: dbo.DISPONIBILIDADE_MOTORISTA_BKUP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[DISPONIBILIDADE_MOTORISTA_BKUP]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[DISPONIBILIDADE_MOTORISTA_BKUP]
AS 
BEGIN
drop table if exists #disponibilidade
select 
	 dpm_dh_data em_dh_data
	,dpm_cd_usuario em_cd_motorista
	,'-' as em_ds_placa
	,tvl_nm_tipo_veiculo em_ds_tipo
	,'F' em_ds_frota
	,c.bss_cd_base em_cd_base
	,dpm_ds_periodo em_ds_ciclo
	,case when dpm_in_disponivel = 1 then 'Não Escalado' else 'Indisponível' end em_ds_escala
		--,case when dpm_in_disponivel = 1 then 'Escalado' else 'Não Escalado' end em_ds_escala

	,dpm_cd_usuario_criacao em_cd_usuario_escala
	,dpm_dh_criacao em_dh_escala
	,a.dpm_cd_cliente

	into #disponibilidade

from tb_disponibilidade_motorista as a 
inner join  tb_dra_tipo_veiculo as b
on a.dpm_cd_tipoVeiculo = b.tvl_cd_tipo_veiculo
inner join tb_bases as c	
on a.dpm_base = c.bss_ds_sigla
and a.dpm_cd_cliente = c.bss_cod_cliente
where cast(dpm_dh_data as date) >= cast(getdate()-5 as date)
 --and  dpm_cd_usuario = 24830  
-- select top 10 * from tb_disponibilidade_motorista

-- transforme a conculta acima em um merge
merge tb_escala_motorista as a
using #disponibilidade as b
on a.em_cd_motorista = b.em_cd_motorista
and a.em_data_referencia  = cast(b.em_dh_data as date)
and a.em_ds_ciclo = b.em_ds_ciclo  and a.em_ds_tipo is not null
and a.em_ds_ciclo is not null


when matched then
update set
em_ds_tipo = b.em_ds_tipo
,em_cd_base = b.em_cd_base
,a.em_ds_ciclo = b.em_ds_ciclo
,a.em_ds_escala = b.em_ds_escala
,a.em_cd_cliente = b.dpm_cd_cliente 
when not matched then
insert (em_data_referencia,em_cd_motorista,em_ds_placa,em_ds_tipo,em_ds_frota,em_cd_base,em_ds_ciclo,em_ds_escala,em_cd_usuario_escala,em_dh_escala)
values (b.em_dh_data,b.em_cd_motorista,b.em_ds_placa,b.em_ds_tipo,b.em_ds_frota,b.em_cd_base,b.em_ds_ciclo,b.em_ds_escala,b.em_cd_usuario_escala,b.em_dh_escala)
;



end
GO
