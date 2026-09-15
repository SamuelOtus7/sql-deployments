-- ============================================================
-- BASELINE: dbo.vw_fin_prefatura
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_prefatura]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_fin_prefatura] as 

        WITH BaseLM AS (
                SELECT 
                        IdTransportadora,
                        IdRota,
                        Quinzena,
                        DataTermino,
                        Ano,
                        Mes,
                        Veiculo,
                        ContinuacaoVeiculo,
                        ServiceCenter,
                        KmCiclo,
                        CicloPM,
                        IntervaloFaixa,
                        InicioIntervalo,
                        FimIntervalo,
                        Dia,
                        DataInicio,
                        DataTermino AS DataFim,
                        Placa,
                        Motorista,
                        Quantidade,
                        PrecoUnitario,
                        Total,
                        Parada,
                        VLParada,
                        DataAtualizacao,
                        EnderecoNaoVisitado,
                        'LM' AS TipoPf
                FROM    tb_fin_prefatura WITH (NOLOCK)
        ),

        BaseMO AS (
            SELECT 
                    IdTransportadora,
                    IdRota,
                    Quinzena,
                    DataTermino,
                    Ano,
                    Mes,
                    Veiculo,
                    ContinuacaoVeiculo,
                    ServiceCenter,
                    KmCiclo,
                    CicloPM,
                    IntervaloFaixa,
                    InicioIntervalo,
                    FimIntervalo,
                    Dia,
                    DataInicio,
                    DataTermino AS DataFim,
                    Placa,
                    Motorista,
                    Quantidade,
                    PrecoUnitario,
                    Total,
                    Parada,
                    VLParada,
                    DataAtualizacao,
                    EnderecoNaoVisitado,
                    'MO' AS TipoPf
            FROM    tb_fin_mo_prefatura WITH (NOLOCK)
        ),

        BaseFM AS (
            SELECT 
                    IdTransportadora,
                    IdRota,
                    Quinzena,
                    DataTermino,
                    Ano,
                    Mes,
                    Veiculo,
                    ContinuacaoVeiculo,
                    ServiceCenter,
                    KmCiclo,
                    CicloPM,
                    IntervaloFaixa,
                    InicioIntervalo,
                    FimIntervalo,
                    Dia,
                    DataInicio,
                    DataTermino AS DataFim,
                    Placa,
                    Motorista,
                    Quantidade,
                    PrecoUnitario,
                    Total,
                    Parada,
                    VLParada,
                    DataAtualizacao,
                    EnderecoNaoVisitado,
                    'FM' AS TipoPf
            FROM    tb_fin_fm_prefatura WITH (NOLOCK)
        )

        -- LM prioritária
        SELECT  *
        --into    #teste
        FROM    BaseLM

        -- MO adiciona as que não existem na LM
        UNION ALL
        SELECT  mo.*
        FROM    BaseMO mo
        WHERE   NOT EXISTS (
                    SELECT 1
                    FROM BaseLM lm
                    WHERE lm.IdTransportadora = mo.IdTransportadora
                      AND lm.IdRota = mo.IdRota
                      AND lm.Quinzena = mo.Quinzena
                      AND lm.DataTermino = mo.DataTermino
                )

        -- FM adiciona as que não existem nem em LM nem em MO
        UNION ALL
        SELECT  fm.*
        FROM    BaseFM fm
        WHERE   NOT EXISTS (
                    SELECT 1
                    FROM BaseLM lm
                    WHERE lm.IdTransportadora = fm.IdTransportadora
                      AND lm.IdRota = fm.IdRota
                      AND lm.Quinzena = fm.Quinzena
                      AND lm.DataTermino = fm.DataTermino
                )
        AND     NOT EXISTS (
                    SELECT 1
                    FROM BaseMO mo
                    WHERE mo.IdTransportadora = fm.IdTransportadora
                      AND mo.IdRota = fm.IdRota
                      AND mo.Quinzena = fm.Quinzena
                      AND mo.DataTermino = fm.DataTermino
                );



GO
