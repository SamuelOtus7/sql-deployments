/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akjfupg
  Autor        : Devin
  Data         : 2026-09-29
  Descrição    : Parametriza o label exibido na coluna StatusEntrega das views
                 vw_pacotes e vw_saas_pacotes para o caso "Coletado em Rota"
                 (not_delivered em ponto de coleta/parada: Status in
                 ('stop','stop_place_prepared') ou TipoPonto = 'pickup').
                 O label passa a ser lido de tb_ml_status_entrega_traducao com a
                 chave sintetica StatusEntrega = 'coletado_em_rota' por cliente
                 (TenantID = cli_cd_codigo_cliente). Sem cadastro, mantem o
                 texto padrao 'Coletado em Rota'.
                 Seed: cliente 27 (Flight Cargo) recebe label 'Coleta', atendendo
                 a regra do Monitoramento (3a visao) — ex.: rota 434538931.
  Rollback     : scripts/rollback/2026/09/011_rollback_CU-86akjfupg_tipo_rota_coleta.sql
  Objetos      : dbo.vw_pacotes, dbo.vw_saas_pacotes, dbo.tb_ml_status_entrega_traducao (INSERT)
  Dependências : dbo.tb_ml_pacotes, dbo.tb_ml_rotas, dbo.tb_ml_traducoes,
                 dbo.tb_ml_status_entrega_traducao, dbo.tb_ml_pnr,
                 dbo.tb_clientes, dbo.DimTempo
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
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_ml_status_entrega_traducao'))
        THROW 50005, 'Tabela dbo.tb_ml_status_entrega_traducao nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL
--    CREATE/ALTER VIEW precisa ser a primeira instrucao do batch — por isso os
--    ALTERs ficam em batches separados por GO.
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
        --CU-86akjfupg: label parametrizavel por cliente via tb_ml_status_entrega_traducao (chave 'coletado_em_rota')
        when tred.StatusEntregaTraduzido = 'Não entregue'
             and isnull(p.SubStatus,'') <> 'transferred'
            then isnull(tcer.StatusEntregaTraduzido,'Coletado em Rota')
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
	--CU-86akjfupg: label customizavel por cliente para o caso 'Coletado em Rota'
	left join tb_ml_status_entrega_traducao tcer with(nolock)
		on tcer.TenantID = cli.cli_cd_codigo_cliente
		and tcer.StatusEntrega = 'coletado_em_rota'
		and tcer.SubStatus is null
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
        --CU-86akjfupg: label parametrizavel por cliente via tb_ml_status_entrega_traducao (chave 'coletado_em_rota')
        when p.StatusEntrega = 'not_delivered'
             and isnull(p.SubStatus,'') <> 'transferred'
            then isnull(tcer.StatusEntregaTraduzido,'Coletado em Rota')
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
        --CU-86akjfupg: join adicionado para resolver o TenantID do cliente (label customizavel)
        left join tb_clientes cli with(nolock) on p.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1
        left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
        left join tb_ml_traducoes t2 on p.TipoEndereco = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'TipoEndereco'
	    left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'
        --CU-86akjfupg: label customizavel por cliente para o caso 'Coletado em Rota'
        left join tb_ml_status_entrega_traducao tcer with(nolock)
            on tcer.TenantID = cli.cli_cd_codigo_cliente
            and tcer.StatusEntrega = 'coletado_em_rota'
            and tcer.SubStatus is null
WHERE
    1 = 1
    and p.DataReferencia >= DATEADD(MONTH, -3, GETDATE())
    and p.Excluido = 0

GO

BEGIN TRY
    --==========================================================================
    -- 3. SEED — label por cliente (parametrizavel)
    --    Cliente 27 = Flight Cargo (cli_id_logistics 643493085, rota 434538931)
    --    Outros clientes: basta INSERT com o TenantID desejado e o label
    --    StatusEntregaTraduzido escolhido para a chave 'coletado_em_rota'.
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM tb_ml_status_entrega_traducao
        WHERE TenantID = 27 AND StatusEntrega = 'coletado_em_rota' AND SubStatus IS NULL
    )
    BEGIN
        INSERT INTO tb_ml_status_entrega_traducao
            (TenantID, StatusEntrega, StatusEntregaTraduzido, SubStatus, SubStatusTraduzido, se_ds_classificacao, DataCriacao)
        VALUES
            (27, 'coletado_em_rota', 'Coleta', NULL, NULL, NULL, GETDATE());
        PRINT 'Seed inserido: TenantID 27 -> coletado_em_rota = ''Coleta''';
    END
    ELSE
        PRINT 'Seed ja existente para TenantID 27 — nada a fazer.';

    --==========================================================================
    -- 4. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM tb_ml_status_entrega_traducao WHERE TenantID = 27 AND StatusEntrega = 'coletado_em_rota')
        THROW 50006, 'Seed TenantID 27 nao encontrado em tb_ml_status_entrega_traducao.', 1;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.vw_pacotes') AND name = 'TipoRota')
        THROW 50007, 'Coluna TipoRota nao deveria existir em dbo.vw_pacotes.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
