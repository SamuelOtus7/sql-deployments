-- ============================================================
-- BASELINE: dbo.vw_saas_pacotes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_pacotes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_saas_pacotes]
as

SELECT
    p.IdPacote IdEntrega,
    r.Id as IdInternoRota,
    p.DataReferencia,
    case
        --Regra alinhada com UspMLAtualizaDeltaIndicadoresRotas (PacotesNaoEntregues)
        when p.StatusEntrega = 'not_delivered'
             and isnull(p.SubStatus,'') <> 'transferred'
             and p.Status not in ('stop', 'stop_place_prepared')
             and isnull(p.TipoPonto,'') <> 'pickup'
            then 'Não Entregue'
        --not_delivered que não atende aos filtros da procedure (pickup/stop/stop_place_prepared)
        when p.StatusEntrega = 'not_delivered'
             and isnull(p.SubStatus,'') <> 'transferred'
            then 'Coletado em Rota'
        else t.tds_ds_traducao
	 end as StatusEntrega,
    case
        when t3.tds_ds_traducao = 'Endereço Ruim' then 'Endereço inválido'
        when t3.tds_ds_traducao = 'Erro de Rota' then 'Fora de Área'
        else isnull(t3.tds_ds_traducao,'Não Categorizado') end  SubStatus,
    t2.tds_ds_traducao TipoEndereco,
    p.Ambulancia,
    case when trim(t.tds_ds_traducao) in('Entregue','Entregue - Place') or t.tds_ds_traducao like 'Transferido para a rota%' then 'Sucesso'
		     when trim(t.tds_ds_traducao) in ('Chegando ao Destino','Pendente','Em rota de entrega','Para expedir','Coletado')
		           or (p.StatusEntrega = 'not_delivered' and isnull(p.SubStatus,'') <> 'transferred'
		               and (p.Status in ('stop', 'stop_place_prepared') or isnull(p.TipoPonto,'') = 'pickup'))
		          then 'Em Andamento'
			 else 'Insucesso'
		end as StatusGeralEntrega,
    DATEADD(MINUTE, DATEDIFF(MINUTE, 0, p.DataHoraEntrega), 0) AS DataHoraEntrega,
    p.QuantidadeReclamacoes,
	p.Cidade,
    --p.EnderecoParada,
    p.IdTransportadora
    --p.Excluido
FROM tb_ml_pacotes as p with(nolock)
        inner join tb_ml_rotas as r with(nolock) on r.IdRota = p.IdRota
			and r.IdTransportadora = p.IdTransportadora and r.Excluido = 0
			and r.StatusRota <> 'planned'
        left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
        left join tb_ml_traducoes t2 on p.TipoEndereco = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'TipoEndereco'
	    left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'
WHERE
    1 = 1
    and p.DataReferencia >= DATEADD(MONTH, -3, GETDATE())
    and p.Excluido = 0

GO
