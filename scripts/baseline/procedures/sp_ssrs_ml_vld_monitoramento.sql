-- ============================================================
-- BASELINE: dbo.sp_ssrs_ml_vld_monitoramento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_ssrs_ml_vld_monitoramento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_ssrs_ml_vld_monitoramento] (
 @XPT varchar(50)
,@base varchar(50)
,@Transportadora int
,@QualXPT varchar(50)
)  
as

-- DECLARE @XPT varchar(max) = 'Ambos'
-- DECLARE @base varchar(max) =  'SSP27'
-- DECLARE @Transportadora INT =  37


if @XPT = 'XPT'
begin
	select * 
	from vw_ssrs_ml_monitoramento 
	where IdTransportadora in (
							select distinct  cli_id_logistics
							from tb_clientes 
							where 1=1 
							and cli_cd_codigo_cliente =  @Transportadora
							and cli_ds_logo_report  is not null
	)
	and servicecenter = @base
	and (OrigemSaida <> @base ) 
AND (OrigemSaida = @QualXPT or @QualXPT ='' )
end

else if @XPT = 'base'
begin
	select * 
	from vw_ssrs_ml_monitoramento 
	where IdTransportadora in (
							select distinct  cli_id_logistics
							from tb_clientes 
							where 1=1 
							and cli_cd_codigo_cliente =  @Transportadora
							and cli_ds_logo_report  is not null
	)
	and servicecenter = @base
	and (OrigemSaida = '' or OrigemSaida is null or OrigemSaida = @base )
end

else if @XPT = 'ambos'
begin
	select * 
	from vw_ssrs_ml_monitoramento 
	where IdTransportadora in (
							select distinct  cli_id_logistics
							from tb_clientes 
							where 1=1 
							and cli_cd_codigo_cliente =  @Transportadora
							and cli_ds_logo_report  is not null
	)
	and servicecenter = @base
	AND (
   @QualXPT = ''    OR origemsaida = @QualXPT
  OR  (OrigemSaida = '' or OrigemSaida is null or OrigemSaida = @base ) 
)

end
GO
