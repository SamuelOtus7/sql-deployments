-- ============================================================
-- BASELINE: dbo.UspAtualzaUsuarioDADia
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualzaUsuarioDADia]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspAtualzaUsuarioDADia]
as


update r
	set r.UsuarioDA = usr_cd_usuario

						
from tb_ml_rotas as r with(nolock)

inner join tb_clientes as cli with(nolock)
on cli.cli_id_logistics = r.IdTransportadora

INNER JOIN tb_usuario AS codusuario WITH (NOLOCK)
ON DBO.fn_remove_acentuacao(r.NomeMotoristA) = DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
                           ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente

where r.DataReferencia >= cast(GETDATE()-1 as date)
and UsuarioDA is null 
and  excluido = 0
and usr_in_ativo = 1
and StatusRota <> 'planned'
--and r.nomemotorista = 'Jonathan da Silva Oliveira'



update r
set r.UsuarioDA = usr_cd_usuario

from tb_ml_fm_rotas as r with(nolock)

inner join tb_clientes as cli with(nolock)
on cli.cli_id_logistics = r.IdTransportadora

INNER JOIN tb_usuario AS codusuario WITH (NOLOCK)
ON DBO.fn_remove_acentuacao(r.NomeMotoristA) = DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
                           ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente

where r.DataReferencia >= cast(GETDATE()-1 as date) and UsuarioDA is null
and  excluido = 0
and usr_in_ativo = 1
and r.UsuarioDA is null 


update r
set r.UsuarioIrisys = usr_cd_usuario

from tb_spe_rotas_v5 as r with(nolock)

inner join tb_clientes as cli with(nolock)
on cli.cli_id_shopee = r.IdTransportadora

INNER JOIN tb_usuario AS codusuario WITH (NOLOCK)
ON  DBO.fn_remove_acentuacao(r.motorista) =  DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
                           ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))

and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente

where r.DataReferencia >= cast(GETDATE()-1 as date) 
AND UsuarioIrisys is null
and  excluido = 0
and usr_in_ativo = 1



update r
set r.UsuarioDA = usr_cd_usuario

from TB_ML_MO_ROTAS as r with(nolock)

inner join tb_clientes as cli with(nolock)
on cli.cli_id_logistics = r.IdTransportadora

INNER JOIN tb_usuario AS codusuario WITH (NOLOCK)
ON DBO.fn_remove_acentuacao(r.NomeMotoristA) = DBO.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
                           ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente

where r.DataReferencia >= cast(GETDATE()-1 as date)
and UsuarioDA is null
and  excluido = 0
and usr_in_ativo = 1

exec UpsAtualizaNivelMotoristas ;
exec uspAtualizaUsuarioInativo;



update 
		r
	set 
		r.UsuarioDA = usr_cd_usuario
	from 
		tb_ml_lh_rotas r with(nolock)
		join tb_clientes cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora
		join tb_usuario codusuario with (nolock) on dbo.fn_remove_acentuacao(r.NomeMotorista) = dbo.fn_remove_acentuacao(LEFT(codusuario.usr_nm_usuario, 
																									ISNULL(NULLIF(CHARINDEX('_', codusuario.usr_nm_usuario) - 1, -1), LEN(codusuario.usr_nm_usuario))))
														and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	where 
		r.DataReferencia >= cast(getdate()-1 as date)
		and excluido = 0
		and usr_in_ativo = 1
		and r.UsuarioDA is null
GO
