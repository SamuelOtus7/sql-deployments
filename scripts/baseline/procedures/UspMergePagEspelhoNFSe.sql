-- ============================================================
-- BASELINE: dbo.UspMergePagEspelhoNFSe
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMergePagEspelhoNFSe]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



															
CREATE   proc [dbo].[UspMergePagEspelhoNFSe]
(
	@cd_espelho           INT,
    @ds_link_xml          VARCHAR(250) = NULL,
    @ds_chave_nfse        VARCHAR(150) = NULL,
    @ds_cnpj_emitente     VARCHAR(14) = NULL,
    @dh_emissao           DATETIME = NULL,
    @cnpj_tomador         VARCHAR(14) = NULL,
    @ds_situacao          VARCHAR(30) = NULL,
	@vl_nota			  DECIMAL(18,8) = NULL,
    @dh_processamento     DATETIME,
    @ds_resultado         VARCHAR(250),
	@cd_servico			  varchar(10),
	@cd_municipio_toma	  varchar(50),
	@cep_toma			  varchar(10), 
	@im_toma			  varchar(50),
	@ds_observacao		  varchar(2000),
	@toma_bairro	      varchar(250),
	@toma_logradouro	  varchar(250),
	@toma_numero		  varchar(20),
	@emit_municipio		  varchar(250),
	@emit_CEP		      varchar(10),
	@emit_bairro		  varchar(250),
	@emit_logradouro	  varchar(250),
	@emit_numero		  varchar(20),
	@numero_nfse		  varchar(10),
	@status_integracao	  INT = NULL

)
AS
BEGIN
    SET NOCOUNT ON;
	
    MERGE tb_pag_espelhos_nfse AS target
    USING (
        SELECT 
            @cd_espelho AS enf_cd_espelho
    ) AS source
    ON target.enf_cd_espelho = source.enf_cd_espelho

    WHEN MATCHED THEN
        UPDATE SET 
            enf_ds_link_xml =		@ds_link_xml,
            enf_ds_chave_nfse =		@ds_chave_nfse,
            enf_ds_cnpj_emitente =	@ds_cnpj_emitente,
            enf_dh_emissao =		@dh_emissao,
            enf_cnpj_tomador =		@cnpj_tomador,
            enf_ds_situacao =		@ds_situacao,
			enf_vl_nota =			@vl_nota,
            enf_dh_processamento =	@dh_processamento,
            enf_ds_resultado =		@ds_resultado,
			enf_cd_servico =		@cd_servico,
			enf_cd_municipio_toma = @cd_municipio_toma,
			enf_cep_toma =			@cep_toma,
			end_im_toma =			@im_toma,
			enf_ds_observacao =		@ds_observacao,
			enf_ds_toma_bairro =	@toma_bairro,
			enf_ds_toma_logradouro =@toma_logradouro,
			enf_ds_toma_numero =	@toma_numero,
			enf_ds_emit_municipio	= @emit_municipio,	  
			enf_ds_emit_CEP		    = @emit_CEP,
			enf_ds_emit_bairro		= @emit_bairro,
			enf_ds_emit_logradouro	= @emit_logradouro,
			enf_ds_emit_numero		= @emit_numero,  
			enf_nr_nfse				= @numero_nfse,
			enf_qt_tentativas = enf_qt_tentativas + 1,
			enf_status_integracao   = @status_integracao

    WHEN NOT MATCHED THEN
        INSERT (
            enf_cd_espelho,
            enf_ds_link_xml,
            enf_ds_chave_nfse,
            enf_ds_cnpj_emitente,
            enf_dh_emissao,
            enf_cnpj_tomador,
            enf_ds_situacao,
			enf_vl_nota,
            enf_dh_processamento,
            enf_ds_resultado,
			enf_qt_tentativas,
			enf_cd_servico,
			enf_cd_municipio_toma,
			enf_cep_toma,
			end_im_toma,
			enf_ds_observacao,
			enf_ds_toma_bairro,
			enf_ds_toma_logradouro,
			enf_ds_toma_numero,
			enf_ds_emit_municipio,	
			enf_ds_emit_CEP,		    
			enf_ds_emit_bairro,		
			enf_ds_emit_logradouro,	
			enf_ds_emit_numero,
			enf_nr_nfse,
			enf_status_integracao
        ) 
        VALUES (
            @cd_espelho,
            @ds_link_xml,
            @ds_chave_nfse,
            @ds_cnpj_emitente,
            @dh_emissao,
            @cnpj_tomador,
            @ds_situacao,
			@vl_nota,
            @dh_processamento,
            @ds_resultado,
			case when @ds_resultado = 'Processado com sucesso!' then 0 else 1 end,
			@cd_servico,
			@cd_municipio_toma,
			@cep_toma,
			@im_toma,
			@ds_observacao,
			@toma_bairro,
			@toma_logradouro,
			@toma_numero,
			@emit_municipio,	  
			@emit_CEP,
			@emit_bairro,
			@emit_logradouro,
			@emit_numero,
			@numero_nfse,
			@status_integracao
        );
END;
GO
