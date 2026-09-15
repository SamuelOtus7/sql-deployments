-- ============================================================
-- BASELINE: dbo.Usp_PacotesDivergentesDaRota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_PacotesDivergentesDaRota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_PacotesDivergentesDaRota] as

DROP TABLE IF EXISTS #base;


declare @data_inicio date = getdate()
declare @data_fim date = getdate()

select

    ROTAS.idtransportadora
    , ROTAS.idrota
    , ROTAS.datareferencia
   -- , rotas.excluido
	, cli.cli_ds_nome
	into #base
from
    (
select
      idtransportadora
    , idrota
    , datareferencia
    , excluido

    from tb_ml_rotas
    where datareferencia between @data_inicio and @data_fim
        and StatusRota <> 'planned'
		and excluido = 0
) as rotas
    left join
    ( 
    select
        idrota
        , idtransportadora
        , cast(datahoraentrega as date) as datahoraentrega
        , count(distinct cast(datahoraentrega as date) ) as dias_entrega
    from tb_ml_pacotes
    where datareferencia between @data_inicio and @data_fim
        and excluido  = 0

    group by idrota
    ,idtransportadora
    ,cast(datahoraentrega as date)
    having count(distinct cast(datahoraentrega as date) ) = 1
) as pacotes
    on rotas.idrota = pacotes.idrota
        and rotas.idtransportadora = pacotes.idtransportadora
        and rotas.datareferencia = pacotes.datahoraentrega
join tb_clientes cli
on rotas.idtransportadora = cli.cli_id_logistics

where 1=1
    --and  rotas.idrota  = 246186879
    and rotas.excluido = 1


		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', IdRota: ' + CONVERT(VARCHAR(3), idrota ) + CHAR(10)
    FROM #base;


    RAISERROR ('Pacotes divergentes da data referencia da rota para os seguintes clientes e rotas, Verificar com o time de Dados:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;


GO
