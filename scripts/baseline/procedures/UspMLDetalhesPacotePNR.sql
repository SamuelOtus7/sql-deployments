-- ============================================================
-- BASELINE: dbo.UspMLDetalhesPacotePNR
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLDetalhesPacotePNR]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[UspMLDetalhesPacotePNR]
as 
begin

  --SET NOCOUNT ON;

INSERT INTO dbo.tb_dra_reprocessamento (
    dar_cd_cliente,
    dar_cd_lista_transportadora,
    dar_cd_lista_operacao,
    dar_cd_rota,
    dar_cd_lista_status,
    dar_cd_lista_acao,
    dar_nr_maximo_tentativas,
    dar_nr_execucoes,
    dar_dh_processamento,
    dar_ds_erro_message,
    dar_dh_criacao,
    dar_cd_pacote
)


select distinct
  c.cli_cd_codigo_cliente    AS dar_cd_cliente,
  1207            AS dar_cd_lista_transportadora,
  1209            AS dar_cd_lista_operacao,
  CAST(p.idrota AS INT)    AS dar_cd_rota,
  1212            AS dar_cd_lista_status,
  1265            AS dar_cd_lista_acao,
  3              AS dar_nr_maximo_tentativas,
  0              AS dar_nr_execucoes,
  NULL            AS dar_dh_processamento,
  NULL            AS dar_ds_erro_message,
  GETDATE()          AS dar_dh_criacao,
  CAST(p.IdPacote AS VARCHAR)  AS dar_cd_pacote

  --,detalhes.NomeComprador
  --,detalhes.Endereco as EnderecoComprador
  --,detalhes.TelefoneComprador

  --,rep.dar_dh_processamento
  --,rep.dar_cd_pacote

from  dbo.tb_ml_rotas r with(nolock)
inner  join dbo.tb_ml_pacotes p with(nolock) 
    on r.idtransportadora = p.idtransportadora and r.idrota = p.idrota and r.datareferencia = p.datareferencia
inner  join dbo.tb_ml_pnr pnr with(nolock) 
    on pnr.IdPacote= p.IdPacote and pnr.IdTransportadora = r.IdTransportadora
left  join dbo.tb_clientes c with(nolock) 
    on r.idtransportadora = c.cli_id_logistics
left  join dbo.tb_ml_traducoes tra with(nolock) 
    on pnr.Status = tra.tds_vl_json and tra.tds_nm_tabela = 'tb_ml_pnr' and tra.tds_nm_campo = 'Status'
left  join dbo.tb_ml_detalhes_pacotes detalhes 
    on detalhes.IdPacote  = p.IdPacote and detalhes.IdTransportadora = p.IdTransportadora

/*Para não gerar uma sobre cargar na tabela de reprocessamento, foi feito uma validação para inserir somente os casos com mais de duas horas da ultima carga*/
left  join dbo.tb_dra_reprocessamento as rep with(nolock) 
    ON p.IdPacote = rep.dar_cd_pacote 

inner join dbo.tb_parametros prm with(nolock)
    on prm.prm_cod_cliente = c.cli_cd_codigo_cliente
   and prm.prm_nm_parametro = 'Habilitar Analise de PNR'
   and prm.prm_ds_valor = 'true'	
WHERE  1=1
and DataReclamacao   >= cast(getdate()-1 as date) 
  AND p.Excluido = 0
and p.SubStatus <> 'transferred'
  AND c.cli_in_ativo = 1
  AND (detalhes.telefonecomprador is null
    OR detalhes.Endereco is null
    OR detalhes.NomeComprador is null)

     and (
        NOT EXISTS (                                                   -- excecao: finalizado que ainda NAO esgotou as tentativas
              SELECT 1
              FROM dbo.tb_dra_reprocessamento rep_fin WITH (NOLOCK)
              WHERE rep_fin.dar_cd_pacote = CAST(p.IdPacote AS VARCHAR)
                --AND rep_fin.dar_nr_execucoes >= rep_fin.dar_nr_maximo_tentativas
                and rep_fin.dar_cd_lista_acao = 1265
                
              )
              );


end

GO
