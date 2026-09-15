-- ============================================================
-- BASELINE: dbo.vw_fin_resultado_quinzenal
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_resultado_quinzenal]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vw_fin_resultado_quinzenal]
AS 
SELECT   
    ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY A.IdTransportadora, A.Ano, A.Mes, A.Quinzena) AS Id,  
    A.IdTransportadora,  
    A.Ano,  
    A.NomeMes,  
    A.Mes,  
    A.Quinzena,  
    A.NomeQuinzena,  
    A.Rotas,  
    A.PreFatura AS SaidaPreFatura,  
    A.Complementar,  
    A.ValorFinal,  
    A.ValorContestacao,  
    A.PercentualConstetacao,  
    ISNULL(B.LostPackages,0) AS LostPackages,  
    ISNULL(B.Pnr,0) AS Pnr,  
    ISNULL(B.EnderecoNaoVisitado,0) AS EnderecoNaoVisitado,  
    A.QtdParada,  
    A.ValorParada,
    A.lst_cd_lista,
    --ISNULL(B.Pnr,0) + ISNULL(B.LostPackages,0) AS TotalDescontos,
	B.TotalDescontos,
    ISNULL(I.TotalImpostos,0) AS SaidaComImpostos, 
	(ISNULL(A.ValorParada,0) + ISNULL(I.TotalImpostos,0))-(ISNULL(B.TotalDescontos,0)) AS TotalPreFatura

FROM (  
    SELECT  
        a.IdTransportadora,  
        a.Ano,  
        a.NomeMes,  
        a.Mes,  
        a.Quinzena,  
        a.NomeQuinzena,  
        COUNT(1) AS Rotas,  
        SUM(a.TotalPreFatura) AS PreFatura,  
        SUM(a.ReceitaDA) - SUM(a.TotalPreFatura) AS Complementar,  
        SUM(a.ReceitaDA) AS ValorFinal,  
        SUM(a.ReceitaDA) - SUM(a.TotalPreFatura) AS ValorContestacao,  
        SUM(a.Parada) AS QtdParada,  
        SUM(a.VlParada) AS ValorParada,  
        CASE   
            WHEN SUM(a.TotalPreFatura) = 0 THEN 0.0   
            ELSE (SUM(a.ReceitaDA) - SUM(a.TotalPreFatura)) / SUM(a.TotalPreFatura)   
        END AS PercentualConstetacao,  
        c.lst_cd_lista  
    FROM  
        vw_validacao_financeiro AS a  
        INNER JOIN tb_clientes AS b  
            ON b.cli_id_logistics = a.IdTransportadora  
        INNER JOIN tb_lista AS c  
            ON c.lst_cd_cliente = b.cli_cd_codigo_cliente  
            AND c.lst_nm_lista = 'Clientes transportadoras'  
            AND c.lst_ds_label = 'Mercado Livre' 
    WHERE   
        b.cli_cd_codigo_cliente <> 7 
        and a.Marketplace = 'Mercado Livre'
        and a.Operacao = 'LM'
    GROUP BY  
        a.IdTransportadora,  
        a.Ano,  
        a.NomeMes,  
        a.Mes,  
        a.Quinzena,  
        a.NomeQuinzena,  
        c.lst_cd_lista  
) AS A   
LEFT JOIN (  
    SELECT   
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena,  
         SUM(CASE WHEN Descricao like 'Lost Packages Penalty%' THEN Total ELSE 0 END) AS LostPackages,  
        SUM(CASE WHEN Descricao like 'Pnr Packages Penalty%' THEN Total ELSE 0 END) AS Pnr,  
        SUM(CASE WHEN Descricao like 'Vehicle Daily Not Visited%' THEN Total ELSE 0 END) AS EnderecoNaoVisitado,
		SUM(Total) TotalDescontos
    FROM   
        dbo.tb_fin_prefatura_descontos  
    GROUP BY  
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena  
) AS B   
    ON A.IdTransportadora = B.idtransportadora  
    AND A.Ano = B.Ano  
    AND A.Mes = B.Mes  
    AND A.Quinzena = B.Quinzena  
LEFT JOIN (  
    SELECT   
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena,  
        SUM(valorimposto) AS TotalImpostos
    FROM   
        dbo.tb_fin_prefatura_impostos  
    GROUP BY  
        idtransportadora,  
        Ano,  
        Mes,  
        Quinzena  
) AS I  
    ON A.IdTransportadora = I.idtransportadora  
    AND A.Ano = I.Ano  
    AND A.Mes = I.Mes  
    AND A.Quinzena = I.Quinzena;
GO
