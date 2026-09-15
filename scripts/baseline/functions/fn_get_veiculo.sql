-- ============================================================
-- BASELINE: dbo.fn_get_veiculo
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_veiculo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       function [dbo].[fn_get_veiculo]
(
	@Transportadora int,
	@ClienteTransportadora varchar(30),
	@SVC varchar(35) = NULL
)

returns table
as return

select distinct top 100
	   tvl_nm_tipo_veiculo as Veiculo
from tb_fin_base_frete_motorista as fin
	join tb_clientes as clientes on fin.bfm_cd_transportadora = clientes.cli_cd_codigo_cliente
	join tb_dra_tipo_veiculo as veic on tvl_cd_tipo_veiculo = bfm_cd_tipo_veiculo
where clientes.cli_cd_codigo_cliente = @Transportadora
	  and bfm_vl_inicio_faixa >= 0
	  and bfm_vl_fim_faixa > bfm_vl_inicio_faixa
      AND (@SVC IS NULL OR fin.bfm_cd_service_center = @SVC)
	  --and tvl_nm_tipo_veiculo = @veiculo

group by tvl_nm_tipo_veiculo
GO
