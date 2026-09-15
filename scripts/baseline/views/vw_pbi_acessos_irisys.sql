-- ============================================================
-- BASELINE: dbo.vw_pbi_acessos_irisys
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pbi_acessos_irisys]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_pbi_acessos_irisys]
as

select 
		cli_cd_codigo_cliente Tenantid,
	  convert(date,log_dh_acesso) as Data,
	  convert(varchar(8),log_dh_acesso,108) as Hora,
	  case when reports.rel_cd_relatorio is null then 'Tela' else 'Relatório' end as TipoAcesso,
	  case when reports.rel_cd_relatorio is null then controllers.ctr_nm_label else isnull(reports.rel_ds_nome,'') end as Objeto,
	  case 
		when reports.rel_cd_relatorio is null 
	    then 
			case actions.act_nm_action 
				when 'GET' then 'Visualizar'
				when 'POST' then 'Inserir'
				when 'PUT' then 'Atualizar'
				when 'PATCH' then 'Atualizar'
				when 'DELETE' then 'Excluir'
				when 'DOWNLOAD' then 'Download'
				when 'UPLOAD' then 'Upload'
			else actions.act_nm_action 
			end 
		else 'Visualizar Relatório'
	  end as Acao,
	  users.usr_nm_usuario as NomeUsuario,
	  users.usr_cd_usuario as CodigoUsuario,
	  users.usr_ds_email as EmailUsuario
	  --org.org_nm_organizacao as Organizacao
      --'MDO' as Organizacao
		
from tb_logs_acessos as logs (nolock)
	join tb_controller as controllers (nolock)on logs.ctr_cd_controller = controllers.ctr_cd_controller
	join tb_action as actions (nolock)on logs.act_cd_action = actions.act_cd_action
	join tb_usuario as users (nolock)on logs.usr_cd_usuario = users.usr_cd_usuario
	--join db_mdo..tb_organizacao as org on users.usr_cod_organizacao = org.org_cod_organizacao
	left join tb_relatorios as reports (nolock) on reports.rel_cd_controller = controllers.ctr_cd_controller
where /*org.org_nm_organizacao = 'Cedro'  and*/ 
(controllers.ctr_nm_label not in ('Controllers', 'Organizacao') or actions.act_nm_action <> 'GET')
and convert(date,log_dh_acesso) >= dateadd(month,-1,convert(date,getdate()))

--and users.usr_nm_usuario = 'Samuel Nogueira'
--and cli_cd_codigo_cliente = 17
GO
