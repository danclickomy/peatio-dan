# this file was recreated by git37 to support staking deposits of POS coins
module Worker
  class DepositCoin

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      sleep 0.5 # nothing result without sleep by query gettransaction api

      channel_key = payload[:channel_key]
      txid = payload[:txid]

      channel = DepositChannel.find_by_key(channel_key)
      if channel.currency_obj.code == 'eth'
        raw  = get_raw_eth txid
        raw.symbolize_keys!
        deposit_eth!(channel, txid, 1, raw)
      else
        raw  = get_raw(channel, txid)
        raw.symbolize_keys!
        deposit_address, txout, staking = get_deposit_address(raw)
        Rails.logger.info "Deposit address: #{deposit_address}, txout #{txout}"
        deposit!(channel, txid, txout, raw, deposit_address, staking)
      end
    end

    def deposit!(channel, txid, txout, raw, deposit_address, staking)

      ActiveRecord::Base.transaction do
        unless PaymentAddress.where(currency: channel.currency_obj.id, address: deposit_address).first
          Rails.logger.info "Deposit address not found, skip. txid: #{txid}, txout: #{txout}, address: #{deposit_address}, amount: #{raw[:amount]}, fee: #{raw[:fee]}, staking: #{staking} "
          return
        end

        fee = 0
        unless raw[:fee].nil?
          fee = raw[:fee]
        end

        amount_after_fees = fee + raw[:amount]
        Rails.logger.info "Trax Details: txid: #{txid}, txout: #{txout}, address: #{deposit_address}, fee: #{fee}, amount#{ raw[:amount]} amount_after_fees: #{amount_after_fees}, staking: #{staking}"
        if(amount_after_fees < 0)
          Rails.logger.info "No deposit. Probably send. txid: #{txid}, txout: #{txout}, address: #{deposit_address}, amount: #{amount_after_fees}, staking: #{staking}"
          return
        end

        Rails.logger.info "OK - Before database. txid: #{txid}, txout: #{txout}, address: #{deposit_address}, amount: #{amount_after_fees}, staking: #{staking}, "

        # ??? return if PaymentTransaction::Normal.where(txid: txid, txout: txout).first
        if staking
          staking_fee = channel.currency_obj.staking_fee
        else 
          staking_fee = 0
        end

        fee = 0

        tx = PaymentTransaction::Normal.create! \
        txid: txid,
        txout: txout,
        address: deposit_address,
        amount: amount_after_fees,
        confirmations: raw[:confirmations],
        receive_at: Time.at(raw[:timereceived]).to_datetime,
        currency: channel.currency,
        staking: staking,
        staking_fee: staking_fee

        deposit = channel.kls.create! \
        payment_transaction_id: tx.id,
        txid: tx.txid,
        txout: tx.txout,
        amount: tx.amount,
        member: tx.member,
        account: tx.account,
        currency: tx.currency,
        confirmations: tx.confirmations,
        staking: staking,
        staking_fee: staking_fee,
        fee: fee
        

        deposit.submit!
      end
    rescue
      Rails.logger.error "Failed to deposit: #{$!}"
      Rails.logger.error "txid: #{txid}, txout: #{txout}"
      Rails.logger.error $!.backtrace.join("\n")
    end

    def deposit_eth!(channel, txid, txout, raw)
      ActiveRecord::Base.transaction do
        unless PaymentAddress.where(currency: channel.currency_obj.id, address: raw[:to]).first
          Rails.logger.info "Deposit address not found, skip. txid: #{txid}, txout: #{txout}, address: #{raw[:to]}, amount: #{raw[:value].to_i(16) / 1e18}"
          return
        end
        return if PaymentTransaction::Normal.where(txid: txid, txout: txout).first
        confirmations = CoinRPC["eth"].eth_blockNumber.to_i(16) - raw[:blockNumber].to_i(16)
        tx = PaymentTransaction::Normal.create! \
        txid: txid,
        txout: txout,
        address: raw[:to],
        amount: (raw[:value].to_i(16) / 1e18).to_d,
        confirmations: confirmations,
        receive_at: Time.now.to_datetime,
        currency: channel.currency

        deposit = channel.kls.create! \
        payment_transaction_id: tx.id,
        txid: tx.txid,
        txout: tx.txout,
        amount: tx.amount,
        member: tx.member,
        account: tx.account,
        currency: tx.currency,
        confirmations: tx.confirmations

        deposit.submit!
        deposit.accept!
      end
    rescue
      Rails.logger.error "Failed to deposit: #{$!}"
      Rails.logger.error "txid: #{txid}, txout: #{txout}, detail: #{raw.inspect}"
      Rails.logger.error $!.backtrace.join("\n")
    end

    def get_raw(channel, txid)
      channel.currency_obj.api.gettransaction(txid)
    end

    def get_raw_eth(txid)
      CoinRPC["eth"].eth_getTransactionByHash(txid)
    end

    def get_deposit_address(raw)
      staking = false
      Rails.logger.info "raw details length: #{raw[:details].length}"
      if raw[:details].length > 1
        staking = true
      end
	  raw[:details].each_with_index do |detail, i|
        detail.symbolize_keys!
        Rails.logger.info "get_deposit_address: account: #{detail[:account]}, categoty: #{detail[:category]}, address: #{detail[:address]}, txout: #{i}"
        if (detail[:account] == "payment" && detail[:category] == "receive")
          return detail[:address], i, staking
        end
      end
      return "", 0, staking
    end
  end
end