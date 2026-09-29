/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akjfupg
  Autor        : Devin
  Data         : 2026-09-29
  Descrição    : Reverte o forward 011: recria vw_pacotes e vw_saas_pacotes com a
                 definicao anterior (label fixo 'Coletado em Rota', sem consulta
                 a tb_ml_status_entrega_traducao e sem o join extra de
                 tb_clientes em vw_saas_pacotes) e remove o seed
                 TenantID 27 / 'coletado_em_rota'.
  Forward ref  : scripts/forward/2026/09/011_forward_CU-86akjfupg_tipo_rota_coleta.sql
  Objetos      : dbo.vw_pacotes, dbo.vw_saas_pacotes, dbo.tb_ml_status_entrega_traducao (DELETE)
  ==============================================================================
  ATENÇÃO: Este script reverte EXATAMENTE o que o forward fez (views restauradas
  a definicao anterior e remocao do seed inserido).
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_pacotes'))
        THROW 50001, 'View dbo.vw_pacotes nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_saas_pacotes'))
        THROW 50002, 'View dbo.vw_saas_pacotes nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--============================================================================
-- 2. SCRIPT DE ROLLBACK (definicao original das views)
--============================================================================

CREATE OR ALTER view [dbo].[vw_pacotes]
as
SELECT 
	p.IdTransportadora
	,cast(p.DataReferencia as datetime) DataReferencia
	,p.Id
	,p.IdPacote IdEntrega
	,p.IdRota
	,r.Id as IdInternoRota
	,p.IdRotaOrigem
	,p.IdRotaDestino
	,case when p.IdRotaOrigem is not null or p.IdRotaDestino is not null then 1 else 0 end Ambulancia
	,p.QuantidadePontosParada Pontos
	,p.SequenciaParada OrdemEntrega
	,case
        --Regra alinhada com UspMLAtualizaDeltaIndicadoresRotas (PacotesNaoEntregues), usando tb_ml_status_entrega_traducao
        when tred.StatusEntregaTraduzido = 'Não entregue'
             and isnull(p.SubStatus,'') <> 'transferred'
             and p.Status not in ('stop', 'stop_place_prepared')
             and isnull(p.TipoPonto,'') <> 'pickup'
            then 'Não Entregue'
        --not_delivered que não atende aos filtros da procedure (pickup/stop/stop_place_prepared)
        when tred.StatusEntregaTraduzido = 'Não entregue'
             and isnull(p.SubStatus,'') <> 'transferred'
            then 'Coletado em Rota'
        else t.tds_ds_traducao
	 end as StatusEntrega
	,case  
        when t3.tds_ds_traducao = 'Endereço Ruim' then 'Endereço inválido'
        when t3.tds_ds_traducao = 'Erro de Rota' then 'Fora de Área'
        else isnull(t3.tds_ds_traducao,'Não Categorizado') end  SubStatus

	,t2.tds_ds_traducao TipoEndereco
	,p.EnderecoParada
	,p.LatitudeEnderecoParada
	,p.LongitudeEnderecoParada
	,case when trim(t.tds_ds_traducao) in('Entregue','Entregue - Place') or t.tds_ds_traducao like 'Transferido para a rota%' then 'Sucesso'
		     when trim(t.tds_ds_traducao) in ('Chegando ao Destino','Pendente','Em rota de entrega','Para expedir','Coletado')
		           or (tred.StatusEntregaTraduzido = 'Não entregue' and isnull(p.SubStatus,'') <> 'transferred'
		               and (p.Status in ('stop', 'stop_place_prepared') or isnull(p.TipoPonto,'') = 'pickup'))
		          then 'Em Andamento'
			 else 'Insucesso'
		end as StatusGeralEntrega
	,p.DataHoraEntrega
	,left(cast(cast(p.DataHoraEntrega as time) as varchar),5) HoraEvento
	,tm.SkTempo
	,p.NomeEtiqueta Etiqueta
	,p.QuantidadeReclamacoes
	,p.DataAtualizacao
    ,'https://envios.adminml.com/logistics/package-management/package/' + cast(P.IdPacote as varchar(30)) as LogisticsPacote
	,p.Cidade
	,pnr.IdReclamacao as IdPNR
	,pnr.Status as StatusPNR
	,    CASE WHEN pnr.IdPacote IS NOT NULL THEN 1 ELSE 0 END AS FlagPNR
	,p.cep


FROM 
	tb_ml_pacotes p with(nolock)
	inner join tb_ml_rotas as r with(nolock) on r.IdRota = p.IdRota
									--	and r.DataReferencia = p.DataReferencia
									and r.IdTransportadora = p.IdTransportadora and r.Excluido = 0 
									and 	 r.StatusRota <> 'planned'

	join tb_clientes cli with(nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 and cli.cli_cd_codigo_cliente <> 7
	join (
			select 
				SkTempo,
				Hora,
				Minuto MinutoInicial,
				Minuto + 15 MinutoFinal
			from
				DimTempo t
		) tm on DATEPART(hour,p.DataHoraEntrega) = tm.Hora and DATEPART(MINUTE,p.DataHoraEntrega) >= tm.MinutoInicial  and DATEPART(MINUTE,p.DataHoraEntrega) < tm.MinutoFinal
	
	left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
	left join tb_ml_traducoes t2 on p.TipoEndereco = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'TipoEndereco'
	left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'
	left join tb_ml_pnr pnr on pnr.IdPacote = p.IdPacote
	left join tb_ml_status_entrega_traducao tred on tred.TenantID = cli.cli_cd_codigo_cliente
		and tred.StatusEntrega = p.StatusEntrega
		and (tred.SubStatus = p.SubStatus or (tred.SubStatus is null and p.SubStatus is null))
where
	p.Excluido = 0
	 and (p.DataReferencia) >= DATEADD(MONTH, -6, GETDATE()) and (p.DataReferencia) <= DATEADD(HOUR, -1, GETDATE())
	--and p.idtransportadora  = 288216524

GO

CREATE OR ALTER view [dbo].[vw_saas_pacotes]
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

BEGIN TRY
    --==========================================================================
    -- 3. REMOVE SEED inserido pelo forward
    --==========================================================================
    DELETE FROM tb_ml_status_entrega_traducao
    WHERE TenantID = 27 AND StatusEntrega = 'coletado_em_rota' AND SubStatus IS NULL;

    --==========================================================================
    -- 4. POS-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM tb_ml_status_entrega_traducao WHERE TenantID = 27 AND StatusEntrega = 'coletado_em_rota')
        THROW 50006, 'Seed TenantID 27 ainda existe em tb_ml_status_entrega_traducao.', 1;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.vw_pacotes') AND name = 'TipoRota')
        THROW 50007, 'Coluna TipoRota ainda existe em dbo.vw_pacotes.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
