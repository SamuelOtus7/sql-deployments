-- ============================================================
-- BASELINE: dbo.UspEncerraContratoCliente
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspEncerraContratoCliente]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [dbo].[UspEncerraContratoCliente]
as


set nocount on

/*

-- Inativar usuários
update usuarios
set usr_in_ativo = 0
,usr_nm_usuario = usr_nm_usuario + '_inativo_' + cast(usuarios.usr_cd_usuario as varchar)
,usr_ds_email = usr_ds_email + '_inativo_' + cast(usuarios.usr_cd_usuario as varchar)
--select clientes.cli_ds_nome, usuarios.usr_cd_usuario, usr_nm_usuario, usr_ds_email, cli_cd_usr_criacao, ultimo_acesso
from tb_usuario as usuarios
	join tb_clientes as clientes on usuarios.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
	left join (select usr_cd_usuario, max(log_dh_acesso) as ultimo_acesso from tb_logs_acessos group by usr_cd_usuario) as logs
	on usuarios.usr_cd_usuario = logs.usr_cd_usuario
where cli_ds_nome = 'Flashlog'
--order by ultimo_acesso desc

-- Inativar cliente
update tb_clientes set cli_in_ativo = 0, cli_ativo_financeiro = 0 where cli_ds_nome = 'Flashlog'

--Remover envios automáticos
update envios
set er_in_desativado = 1
--select *
from tb_envio_relatios as envios
	join tb_clientes as clientes on envios.er_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
where clientes.cli_ds_nome = 'Flashlog' and envios.er_in_desativado = 1 and er_in_excluido = 0



-- Remover grupo de Whatsapp

-- Inativar worker no mongo
--db.workers.updateMany({carrier:'Flashlog', isEnabled: true}, {$set:{ isEnabled: false }})

-- Remover App da loja
*/

GO
