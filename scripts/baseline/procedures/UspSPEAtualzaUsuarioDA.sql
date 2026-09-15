-- ============================================================
-- BASELINE: dbo.UspSPEAtualzaUsuarioDA
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualzaUsuarioDA]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPEAtualzaUsuarioDA]
(
@data_ini as date
) as

--declare @data_ini as date = cast(getdate()-5 as date)
declare @data_fim as date = cast(getdate() as date)


update a
set
	a.UsuarioIrisys = c.usr_cd_usuario
	
from tb_spe_rotas_v5 as a with(nolock)

inner join tb_spe_motoristas as b
on a.IdMotorista = b.IdMotorista 

left join (
	select usu.*,cli_id_shopee
	from tb_usuario as usu
	inner join tb_clientes as cli
	on usu.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente
	where cli.cli_cd_codigo_cliente <> 7 
	and usr_in_ativo = 1
	) as c
on b.nome = c.usr_nm_usuario
and a.idtransportadora = c.cli_id_shopee


where DataReferencia between @data_ini and @data_fim
and UsuarioIrisys is null 
and c.usr_nm_usuario is not null

GO
