-- ============================================================
-- BASELINE: dbo.fn_pagamentos_zerados_hawk
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_pagamentos_zerados_hawk]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_pagamentos_zerados_hawk]
(
    @IdPeriodo INT = NULL,
    @Rota INT = NULL
)
RETURNS @Resultado TABLE
(
    CodigoEspelho INT,
    DataReferencia DATE,
    Contrato VARCHAR(200),
    Motorista VARCHAR(200),
    Base VARCHAR(50),
    TipoVeiculo VARCHAR(100),
    Cidade VARCHAR(100),
    IdRota VARCHAR(100),
    Status VARCHAR(200),
    DataAtualizacaoControlePowerBI DATETIME
)
AS
BEGIN

    DECLARE @IdCliente INT;
    DECLARE @UtilizaContrato INT;

 --DECLARE @IdPeriodo INT = 1926;
 --DECLARE @Rota varchar(50)  = null;

set @IdCliente       = (
                        select  distinct pgp_cd_cliente
                        from    tb_pgto_periodo as pgto
                        where   pgp_cd_periodo = @IdPeriodo

                        )


set @UtilizaContrato = (
					 	select distinct prm_ds_valor 
						from tb_parametros 
						where prm_ds_categoria = 'Financeiro - Pagamentos'
						and prm_nm_parametro = 'Utiliza contrato'
						and prm_cod_cliente = @IdCliente
						)



--select  @IdCliente, @UtilizaContrato

---DOCUMENTAÇÃO DOS CODIGOS DE ERRO
--select	*
--from	tb_lista
--where	lst_nm_lista = 'Status de Erros Validação Espelho'

    INSERT INTO @Resultado
    SELECT 
        r.ppr_cd_pgto_espelho,
        r.ppr_data_referencia,
        CASE 
            WHEN @UtilizaContrato = 0 
                THEN 'Cadastro Padrao'
            ELSE ISNULL(c.ttc_nm_tipo, 'Sem contrato atribuido')
        END AS Contrato,
        r.ppr_nome_motorista,
        r.ppr_base_principal,
        r.ppr_ds_tipo_veiculo,
        r.ppr_nm_cidade,
        r.ppr_cd_rota,
        CASE  
            WHEN r.ppr_vl_base > 0 
                THEN 'Cadastro OK'
            WHEN r.ppr_cd_desconto_ds = 1
                THEN 'Desconto de sucessos na entrega'
            WHEN frete.bfm_vl_inicio_faixa IS NULL 
                 AND frete_cidade.bfm_vl_inicio_faixa IS NULL 
                THEN 'Sem base cadastrada'
            WHEN @UtilizaContrato = 1 AND c.ttc_nm_tipo IS NULL
                THEN 'Sem contrato atribuido'
            WHEN @UtilizaContrato = 1 
                 AND b.pgp_cd_tipo_contratos <> m.mot_ctn_cd_tipo_contrato
                THEN 'Contrato diferente do periodo'
            WHEN r.ppr_total_km IS NULL or r.ppr_total_km = 0
                THEN 'Código 1 - Acionar o suporte'
            WHEN r.ppr_nm_cidade <> frete_cidade.bfm_nm_cidade
                THEN 'Cidade com nomeclaturas diferentes'
            ELSE 'Motivo nao mapeado'
        END AS Status,
        CAST(
            CASE 
                WHEN b.pgp_dt_inicio >= DATEADD(DAY,-60,CAST(GETDATE() AS DATE))
                    THEN CAST(GETDATE() AS DATE)
                ELSE b.pgp_dt_inicio
            END AS DATETIME
        ) AS DataAtualizacaoControlePowerBI
    FROM tb_pgto_periodo_rota r
    LEFT JOIN tb_motorista m
        ON r.ppr_cd_motorista = m.mot_cd_usuario
    LEFT JOIN tb_tipo_contrato c
        ON c.ttc_cd_tipo_contrato = m.mot_ctn_cd_tipo_contrato
    LEFT JOIN tb_dra_tipo_veiculo veic
        ON veic.tvl_nm_tipo_veiculo = r.ppr_ds_tipo_veiculo
    LEFT JOIN tb_pgto_periodo b
        ON b.pgp_cd_periodo = r.ppr_cd_periodo

    -- FRETE BASE
    LEFT JOIN tb_fin_base_frete_motorista frete
        ON frete.bfm_cd_transportadora = b.pgp_cd_cliente
       AND frete.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND frete.bfm_cd_service_center = r.ppr_base_principal
       AND (
            (@UtilizaContrato = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(frete.bmf_cd_tipo_contrato,-1))
            OR @UtilizaContrato = 0
       )
       AND ISNULL(r.ppr_total_km,0) BETWEEN frete.bfm_vl_inicio_faixa - 1 AND frete.bfm_vl_fim_faixa - 1
       AND frete.bfm_nm_cidade IS NULL
       AND r.ppr_data_referencia BETWEEN frete.bfm_data_inicio_vigencia 
           AND ISNULL(frete.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))

    -- FRETE CIDADE
    LEFT JOIN tb_fin_base_frete_motorista frete_cidade
        ON frete_cidade.bfm_cd_transportadora = b.pgp_cd_cliente
       AND frete_cidade.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND frete_cidade.bfm_cd_service_center = r.ppr_base_principal
       AND frete_cidade.bfm_nm_cidade = r.ppr_nm_cidade
       AND (
            (@UtilizaContrato = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(frete_cidade.bmf_cd_tipo_contrato,-1))
            OR @UtilizaContrato = 0
       )
       AND ISNULL(r.ppr_total_km,0) BETWEEN frete_cidade.bfm_vl_inicio_faixa - 1 AND frete_cidade.bfm_vl_fim_faixa - 1
       AND r.ppr_data_referencia BETWEEN frete_cidade.bfm_data_inicio_vigencia 
           AND ISNULL(frete_cidade.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))

    WHERE r.ppr_vl_base = 0
      AND r.ppr_cd_periodo >= 370
      AND (@IdPeriodo IS NULL OR r.ppr_cd_periodo = @IdPeriodo)
      AND (@Rota IS NULL OR r.ppr_cd_rota = @Rota);

    RETURN;
END;
GO
