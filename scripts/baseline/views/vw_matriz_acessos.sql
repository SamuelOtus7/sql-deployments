-- ============================================================
-- BASELINE: dbo.vw_matriz_acessos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_matriz_acessos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_matriz_acessos] as 

select 
gpa_cd_grupo_acesso	
,gpa_nm_grupo_acesso	
,gpa_ds_grupo_acesso
,b.*

from tb_grupo_acesso as a
left join (
	SELECT 
		 data
		,Objeto	
		,Acao
		,count(*) qtd
	
	FROM [vw_pbi_acessos_irisys]
	WHERE data >= '2024-05-01'
	--and Tenantid = 27
	group by Objeto	,Acao,data
) as b
on a.gpa_nm_grupo_acesso  = b.Objeto
where gpa_in_ativo = 1 
--gpa_nm_grupo_acesso = 'Gestão de pedágios'

/*
select clientes.cli_ds_nome as Tenant,
       Module,
       Feature,
       Qty
from (
        select 'Financeiro' as Module,
            'Sinistros' as Feature,
            sin_cd_transportadora as Tenant,
            count(*) as Qty
        from tb_sin_sinistro
        where sin_dh_criacao >= dateadd(day,-15,getdate())
            and sin_in_ativo = 1
            and sin_in_excluido = 0
        group by sin_cd_transportadora
        union all
        select 'Controle' as Module,
            'Indicadores Diários' as Feature,
            ind_cd_transportadora Tenant,
            count(*) as Qty
        from tb_indicadores_diarios
        where ind_dh_criacao >= dateadd(day,-15,getdate())
            and ind_in_ativo = 1
        group by ind_cd_transportadora
) as Base
    join tb_clientes as Clientes on Base.Tenant = Clientes.cli_cd_codigo_cliente
	*/

GO
