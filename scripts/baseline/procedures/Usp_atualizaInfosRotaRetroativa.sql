-- ============================================================
-- BASELINE: dbo.Usp_atualizaInfosRotaRetroativa
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_atualizaInfosRotaRetroativa]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Usp_atualizaInfosRotaRetroativa]

as
begin

-- Atualiza o nome do motorista nas rotas
UPDATE A
SET 
    A.NomeMotorista = B.dhr_ds_nome_motorista
FROM tb_ml_rotas AS A
INNER JOIN tb_dra_historico_rotas AS B
    ON A.idrota = B.dhr_nr_rota
WHERE 
   (A.NomeMotorista IS NULL OR A.NomeMotorista = '')
    AND B.dhr_ds_nome_motorista IS NOT NULL
    AND B.dhr_ds_nome_motorista <> ''
    AND A.DataReferencia >= DATEADD(DAY, -4, GETDATE());

-- Atualiza informações de cidade, estado e endereço das estações
UPDATE B
SET 
    B.Cidade    = A.bss_ds_cidade,
    B.Estado    = A.bss_ds_estado,
    B.Endereco  = A.bss_ds_endereco
FROM TB_BASES AS A
INNER JOIN tb_spe_station AS B
    ON A.bss_ds_nome = B.nomeStation
    AND A.bss_cd_idtransportadora = B.idtransportadora
WHERE 
    B.Cidade IS NULL OR B.Cidade = '';

    end
GO
