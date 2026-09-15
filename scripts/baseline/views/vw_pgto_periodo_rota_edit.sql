-- ============================================================
-- BASELINE: dbo.vw_pgto_periodo_rota_edit
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_periodo_rota_edit]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_pgto_periodo_rota_edit] as 

--select 
--*
--,cast(case when edit_dh_criacao >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else edit_dh_criacao end as datetime) as DataAtualizacaoControlePowerBI
--from tb_pgto_periodo_rota_edit


--GO
SELECT 
    edit_cd_edit,
    edit_rota,
    edit_cd_periodo,
    Coluna,
    Valor,
    edit_dh_criacao,
    edit_cd_espelho,
    edit_cd_usr_criacao,
    --usr_nm_usuario,
    CAST(
        CASE 
            WHEN edit_dh_criacao >= DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) 
                THEN CAST(GETDATE() AS DATE) 
            ELSE edit_dh_criacao 
        END AS DATETIME
    ) AS DataAtualizacaoControlePowerBI
FROM (
    SELECT 
        edit_cd_edit,
        edit_rota,
        edit_cd_periodo,
        CAST(edit_cd_espelho AS VARCHAR(MAX)) AS edit_cd_espelho,
        CAST(edit_Service_Center AS VARCHAR(MAX)) AS [Service Center],
        CAST(edit_Tipo_Veiculo AS VARCHAR(MAX)) AS [Tipo Veiculo],
        CAST(edit_Faixa_KM AS VARCHAR(MAX)) AS [Faixa KM],
        CAST(edit_Ciclo_PM AS VARCHAR(MAX)) AS [Ciclo PM],
        CAST(edit_Placa AS VARCHAR(MAX)) AS Placa,
        CAST(edit_Quantidade_Pontos AS VARCHAR(MAX)) AS [Quantidade Pontos],
        CAST(edit_Quantidade_Paradas AS VARCHAR(MAX)) AS [Quantidade Paradas],
        CAST(edit_cd_usr_criacao AS VARCHAR(MAX)) AS edit_cd_usr_criacao,
        CAST(edit_dh_criacao AS VARCHAR(MAX)) AS edit_dh_criacao,
        CAST(edit_Quantidade_Pacotes AS VARCHAR(MAX)) AS [Quantidade Pacotes],
        CAST(edit_usou_app AS VARCHAR(MAX)) AS [Usou App],
        CAST(edit_Observacao AS VARCHAR(MAX)) AS Observacao,
        CAST(edit_Regiao AS VARCHAR(MAX)) AS Regiao,
        CAST(edit_RiscoV2 AS VARCHAR(MAX)) AS RiscoV2,
        CAST(edit_Ajudante AS VARCHAR(MAX)) AS Ajudante,
        CAST(edit_AreaRisco AS VARCHAR(MAX)) AS [Area Risco],
        CAST(edit_cidade AS VARCHAR(MAX)) AS Cidade,
        CAST(edit_Total_KM AS VARCHAR(MAX)) AS [Total KM]
    FROM tb_pgto_periodo_rota_edit a with(nolock)
    where edit_cd_espelho is not null
) AS src
UNPIVOT
(
    Valor FOR Coluna IN (
        [Service Center],
        [Tipo Veiculo],
        [Faixa KM],
        [Ciclo PM],
        Placa,
        [Quantidade Pontos],
        [Quantidade Paradas],
        [Quantidade Pacotes],
        [Usou App],
        Observacao,
        Regiao,
        RiscoV2,
        Ajudante,
        [Area Risco],
        Cidade,
        [Total KM]
    )
) AS unpvt
--LEFT JOIN tb_usuario b with(nolock)
--    ON edit_cd_usr_criacao = b.usr_cd_usuario;

GO
