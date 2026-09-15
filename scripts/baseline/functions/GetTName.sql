-- ============================================================
-- BASELINE: dbo.GetTName
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[GetTName]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetTName] (
	@IdTransportadora int,
	@MarketPlace_M_or_S char(1) = 'M'
)
returns varchar(100)
as
begin
	return (
				select top 1cli_ds_nome
				from tb_clientes 
				where case when @MarketPlace_M_or_S = 'M' then cli_id_logistics else cli_id_shopee end = @IdTransportadora
				and cli_id_logistics > 0
		   )
end
GO
