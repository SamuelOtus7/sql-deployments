-- ============================================================
-- BASELINE: dbo.IdMl
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[IdMl]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[IdMl] (
	@NomeTransportadora varchar(100)
)
returns int
as
begin
	return (select cli_id_logistics from tb_clientes where cli_ds_nome = @NomeTransportadora)
end
GO
