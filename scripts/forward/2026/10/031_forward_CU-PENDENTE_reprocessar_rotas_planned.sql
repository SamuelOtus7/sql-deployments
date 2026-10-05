/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-PENDENTE (id da task a definir pelo solicitante)
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-05
  Descrição    : Inclui nova branch no UNION do INSERT em
                 tb_rotas_para_reprocessar na dbo.UspMLReprocessarRotas:
                 reprocessa rotas que permaneceram com
                 tb_ml_rotas.statusrota = 'planned' mas tiveram registro na
                 tb_dra_historico_rotas (mesma rota, transportadora e data),
                 desde que a mesma rota/transportadora NAO possua linha em
                 tb_ml_rotas com status 'active' ou 'close'.
                 Demais regras do UNION permanecem inalteradas.
  Rollback     : scripts/rollback/2026/10/031_rollback_CU-PENDENTE_reprocessar_rotas_planned.sql
  Objetos      : CREATE OR ALTER PROCEDURE dbo.UspMLReprocessarRotas
  Dependências : tb_rotas_para_reprocessar, dbo.UspMLInsereRotasReprocessadas,
                 dbo.UspMLAtualizaDeltaIndicadoresRotas, tb_ml_rotas,
                 tb_ml_pacotes, tb_dra_historico_rotas, tb_clientes, vw_rotas,
                 db_Irisys_Json.dbo.tb_ml_coleta_rotas
  ==============================================================================*/

SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[UspMLReprocessarRotas]
as
begin

 SET NOCOUNT ON;

 truncate table tb_rotas_para_reprocessar

 --Atualiza delta indicadores
 exec [UspMLAtualizaDeltaIndicadoresRotas] 5

 drop table if exists #historico
 select
  distinct
  dhr_cd_cliente IdTransportadora,
  dhr_nr_rota IdRota,
  dhr_dt_data DataReferencia
  into #historico
 from
  tb_dra_historico_rotas with(nolock)
 where
  dhr_dt_data >= cast(getdate()-10 as date)


 drop table if exists #historico_veiculos
 select
  h.dhr_cd_cliente IdTransportadora
  ,h.dhr_nr_rota IdRota
  ,h.dhr_dt_data DataReferencia
  ,h.dhr_ds_veiculo TipoVeiculo
  into #historico_veiculos
 from
  tb_dra_historico_rotas h with(nolock)
  join (
   select
    dhr_cd_cliente
    ,dhr_nr_rota
    ,max(dhr_dh_coleta) dhr_dh_coleta
   from
    tb_dra_historico_rotas with(nolock)
   where
    dhr_dt_data >= cast(getdate()-5 as date)
   group by
    dhr_cd_cliente
    ,dhr_nr_rota
  ) h2 on h.dhr_cd_cliente = h2.dhr_cd_cliente
   and h.dhr_nr_rota = h2.dhr_nr_rota
   and h.dhr_dh_coleta = h2.dhr_dh_coleta
 where
  h.dhr_dt_data >= cast(getdate()-10 as date)
  and h.dhr_ds_veiculo <> ''



 --Insere rotas que manteve diferença nos indicadores ou que não foram finalizadas
 insert into tb_rotas_para_reprocessar (IdRota, DataReferencia, IdTransportadora)


 --reprocessa rotas fechadas que ainda tem pacotes pendentes
 select
  IdRota
  ,DataReferencia
  ,IdTransportadora
 from
  vw_rotas
 where
  StatusRota = 'Fechada'
  and PacotesPendentes > 0
  and DataReferencia >= dateadd(day,-10,cast(getdate() as date))

union

--reprocesas rotas sem driver id
 select
  IdRota
  ,DataReferencia
  ,IdTransportadora
 from
  tb_ml_rotas
 where
	excluido = 0
	and StatusRota <> 'planned'
	and driverid is null
	and DataReferencia >= dateadd(day,-10,cast(getdate() as date))

 union

 --reprocessa rotas que tiveram divergencia entre o tipo de veiculo coletado no monitoramento (tb_ml_rotas) x tipo de veiculo da tabela de histórico (tb_dra_historico_rotas)
 select
  r.IdRota
  ,r.DataReferencia
  ,r.IdTransportadora
 from
  tb_ml_rotas r with(nolock)
  join #historico_veiculos h on r.IdTransportadora = h.IdTransportadora
         and r.IdRota = h.IdRota
 where
  isnull(r.TipoVeiculo,'') <> h.TipoVeiculo
  and statusrota <> 'planned'
  and excluido = 1

 union

 select
  IdRota
  ,DataReferencia
  ,IdTransportadora
 from
  tb_ml_rotas with(nolock)
 where
  statusrota <> 'planned'
  and (NomeMotorista is null or NomeMotorista = '' or NomeMotorista = '-')
  and DataReferencia >= dateadd(day,-2,cast(getdate() as date))

 union

 SELECT
  dhr_nr_rota AS IdRota,
  dhr_dt_data AS DataReferencia,
  dhr_cd_cliente AS IdTransportadora
  -- count(*)  as Total
 FROM (
  SELECT
   dhr_cd_cliente,
   dhr_dt_data,
   dhr_nr_rota
  FROM tb_dra_historico_rotas
  WHERE dhr_dt_data >= cast(getdate()-2 as date)
  GROUP BY
   dhr_cd_cliente,
   dhr_dt_data,
   dhr_nr_rota
 ) AS RotasMeli
 LEFT JOIN tb_ml_rotas AS r
  ON RotasMeli.dhr_cd_cliente = r.IdTransportadora
  -- AND RotasMeli.dhr_dt_data = r.DataReferencia
  AND RotasMeli.dhr_nr_rota = r.IdRota
 WHERE r.IdRota IS NULL

 union

 select
  r.IdRota
  ,r.DataReferencia
  ,r.IdTransportadora
 from
  #historico r
  join tb_clientes c on r.IdTransportadora = c.cli_id_logistics and c.cli_cd_codigo_cliente <> 7 and c.cli_in_ativo = 1
  left join vw_rotas r2 on r.Idrota = r2.IdRota and r.IdTransportadora = r2.IdTransportadora
 where
  r2.Idrota is null

 union


 select distinct
   IdRota,
    DataReferencia,
   IdTransportadora
 from tb_ml_pacotes

 where idrota  in (
 Select
 a.idrota
 from tb_ml_rotas as a
 INNER JOIN tb_clientes AS b  WITH(NOLOCK)
 ON cli_id_logistics = idtransportadora

 where datareferencia between cast(getdate()-10 as date) and cast(getdate()-1 as date)
 and excluido = 0
 and StatusRota <> 'planned'
 and pacotespendentes > 0
 and cli_ds_nome = 'Rodoprime'
 )
 and StatusEntrega = 'pending'

 union


 SELECT
   A.IDROTA
     ,A.DATAREFERENCIA
     ,A.IDTRANSPORTADORA
 FROM tb_ml_rotas AS a WITH (NOLOCK)
 LEFT JOIN tb_ml_pacotes AS b WITH (NOLOCK)
     ON a.idrota = b.idrota
 LEFT JOIN db_Irisys_Json.dbo.tb_ml_coleta_rotas AS c WITH (NOLOCK)
     ON a.idrota = c.cmr_cd_rota
 INNER JOIN tb_dra_historico_rotas AS d WITH (NOLOCK)
     ON a.idrota = d.dhr_nr_rota
 WHERE
     a.idrota IS NOT NULL
     AND b.idrota IS NULL
     AND c.cmr_cd_rota IS NULL
     AND d.dhr_nr_rota IS NOT NULL
     AND d.dhr_nr_envios_entregues > 0
  and a.datareferencia between cast(getdate()-5 as date) and cast(getdate()-1 as date)

  Union

  SELECT Distinct
          a.idrota,
    a.datareferencia,
      a.IdTransportadora
  FROM tb_ml_rotas a with(nolock)
  LEFT JOIN tb_ml_pacotes b with(nolock)
         ON a.idrota = b.idrota
  Join tb_dra_historico_rotas c
  on a.idrota = c.dhr_nr_rota
  WHERE b.idrota IS NULL
    AND a.datareferencia >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
   -- and a.IdTransportadora = 1950609251
    and a.excluido = 0
    and a.statusRota <>'planned'
    and a.PacotesEntregues <> c.dhr_nr_envios_entregues

   union

   SELECT distinct
      a.dhr_nr_rota,
      a.dhr_dt_data,
      a.dhr_cd_cliente
  FROM
  (
      SELECT
          dhr_dt_data,
          dhr_nr_rota,
          dhr_cd_cliente
      FROM tb_dra_historico_rotas WITH (NOLOCK)
      WHERE dhr_nr_envios_entregues > 0
        AND dhr_dt_data  >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
      GROUP BY dhr_dt_data, dhr_nr_rota, dhr_cd_cliente
  ) AS a
  INNER JOIN tb_ml_rotas AS b
          ON a.dhr_nr_rota = b.idrota
  LEFT JOIN (
          SELECT idrota, COUNT(*) AS TotalPacotes
          FROM tb_ml_pacotes WITH (NOLOCK)
          WHERE datareferencia  >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
          GROUP BY idrota
  ) AS p
          ON b.idrota = p.idrota
  WHERE b.excluido = 0
    AND b.statusrota <> 'planned'
    AND ISNULL(p.TotalPacotes, 0) = 0
  --  and b.IdTransportadora = 1950609251
  GROUP BY a.dhr_dt_data, a.dhr_cd_cliente, a.dhr_nr_rota

  union


   select distinct
          a.idrota,
    a.datareferencia,
      a.IdTransportadora
   from tb_ml_rotas a
   join tb_dra_historico_rotas b
   on a.idrota = b.dhr_nr_rota
   where  dhr_nr_envios_entregues > a.PacotesEntregues + a.PacotesEntreguesForaAreaEntrega
   and a.datareferencia >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
  -- and a.IdTransportadora = 1950609251
   and a.statusRota <>'planned'
   and a.excluido = 0

   union

   select distinct
          a.idrota,
    a.datareferencia,
      a.IdTransportadora
   from tb_ml_rotas a with(nolock)
   join tb_ml_pacotes b with(nolock)
   on a.idrota = b.idrota
   left join tb_dra_historico_rotas c
   on a.idrota = c.dhr_nr_rota
   where statusentrega ='pending'
   and a.datareferencia >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
  -- and a.datareferencia <> '2025-11-27'
  -- and a.IdTransportadora = 678279205
   and a.statusRota <>'planned'
   and a.excluido = 0
   and a.pacotesentregues <> c.dhr_nr_envios_entregues

   union

   --reprocessa rotas que permaneceram 'planned' mas tiveram registro no historico DRA;
   --nao pode existir a mesma rota/transportadora com status 'active' ou 'close' em tb_ml_rotas
   select distinct
          a.idrota,
    a.datareferencia,
      a.IdTransportadora
   from tb_ml_rotas a with(nolock)
   join tb_dra_historico_rotas d with(nolock)
   on a.idrota = d.dhr_nr_rota
   and a.idtransportadora = d.dhr_cd_cliente
   and a.datareferencia = d.dhr_dt_data
   where a.statusrota = 'planned'
   and a.excluido = 0
   and a.datareferencia >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
   and not exists (
          select 1
          from tb_ml_rotas x with(nolock)
          where x.idrota = a.idrota
            and x.idtransportadora = a.idtransportadora
            and x.statusrota in ('active','close')
   )

  exec [UspMLInsereRotasReprocessadas]
  exec [UspMLAtualizaDeltaIndicadoresRotas]


 -------------- trecho adicionado para remover rotas que permaneceram como planned ou que não tiveram entrega.

--update a
--set excluido = 1
--from tb_ml_rotas a
--where datareferencia between '2025-09-16' and dateadd(day, -1, getdate())
--  and totalpacotes = 0
--  and excluido = 0
--  and StatusRota <> 'planned'
--  and not exists (
--        select 1
--        from tb_ml_pacotes b
--        where b.idrota = a.idrota
--          and b.idtransportadora = a.idtransportadora
--          and b.StatusEntrega = 'delivered'
--  )
end
GO

BEGIN TRY
    IF OBJECT_ID(N'dbo.UspMLReprocessarRotas') IS NULL
        THROW 51000, 'Falha: procedure nao encontrada apos deploy.', 1;
    PRINT 'SUCESSO: UspMLReprocessarRotas atualizada.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
