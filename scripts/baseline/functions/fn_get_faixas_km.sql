-- ============================================================
-- BASELINE: dbo.fn_get_faixas_km
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_faixas_km]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_get_faixas_km]
(
	@Transportadora int,
	@ClienteTransportadora varchar(30)
	-- @SVC varchar(30) = NULL
)

returns table
as return

select top 100
	   cast(bfm_vl_inicio_faixa as varchar(10)) + '/' + cast(bfm_vl_fim_faixa as varchar(10)) as Faixa
from tb_fin_base_frete_motorista as fin
	join tb_clientes as clientes on fin.bfm_cd_transportadora = clientes.cli_cd_codigo_cliente
where clientes.cli_cd_codigo_cliente = @Transportadora
	  and bfm_vl_inicio_faixa > 0
	  and bfm_vl_fim_faixa > bfm_vl_inicio_faixa
	  and @ClienteTransportadora = 'Mercado Livre'
    --   AND (@SVC IS NULL OR fin.bfm_cd_service_center = @SVC)
group by bfm_vl_inicio_faixa, bfm_vl_fim_faixa
order by bfm_vl_inicio_faixa
GO
