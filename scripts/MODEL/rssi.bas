rem by vodkabears
rem https://github.com/vodka-bears/ersky9x-betaflight-vtx-script
rem derivative of this
rem https://github.com/midelic/Ersky9x-Tx-bas-scripts/blob/master/src/BF_basic.bas

rem dear midelic
rem your code formatting sucks
rem really

rem A script to simply push RSSI every UPDATE_FREQ*10 ms
rem put in /scripts/model
rem works only with smartport
rem due to a bug (?) a name of this file must be 6 symbols max

if init = 0
	init = 1

	SPORT_MSP_VERSION = 32
	SPORT_MSP_STARTFLAG = 16
	LOCAL_SENSOR_ID = 0x0D
	REMOTE_SENSOR_ID = 0x1B
	REQUEST_FRAME_ID = 0x30
	REPLY_FRAME_ID  = 0x32
	MSP_SET_TX_INFO = 186
	MSP_SET_RTC = 246
	UPDATE_FREQ = 50
	RSSI_MULT = 262
	RSSI_DIV = 100
	RSSI_OFFSET = -1

	sportMspSeq = 0
	sportMspRemoteSeq = 0
	sportMspRemoteSeqm = 0
	rem --- Rx values
	array byte mspRxBuf[32]
	mspRxIdx = 1
	mspRxCRC = 0
	mspStarted = false
	mspLastReq = 0
	
	rem --- TX values
	array byte mspTxBuf[34]
	mspTxIdx = 1
	mspTxCRC = 0
	mspTxPk = 0

	mspRequestsSent = 0
	mspRepliesReceived = 0
	mspPkRxed = 0
	mspErrorPk = 0
	mspStartPk = 0
	mspOutOfOrder = 0
	mspCRCErrors = 0
	
	array byte payload[7]
	array byte payloadTx[7]
	array byte payloadReq[32]
	array byte values[32]
	array byte value[32]
	
	val = 0
	lastReqTS = 0	
	result = 0
	startm = 0
	headm = 0
	err_flag = 0
	now = 0
	seq = 0
	ret = 0
	
	lastRunTS = 0
	
	if sysflags() & 0x1
		drawtext(0,32, "RUNS", INVERS)
	end
	
end

goto run

mspSendRequest:
	rem -- busy
	if t_size != 0
		return
	end

	mspTxBuf[1] = p_size
	mspTxBuf[2] = cmnd & 0xFF

	if p_size >= 1
		j=1
		while  j <= p_size
			mspTxBuf[j+2] = payloadReq[j]
			j=j+1
		end
	end

	mspLastReq = cmnd
	mspRequestsSent = mspRequestsSent + 1
	t_size = p_size + 2
	gosub mspProcessTxQ
return

mspProcessTxQ:
	if t_size = 0
		return
	end
	rem ---need here code to check if the previous frame is sent before send the next
	rest = sportTelemetrySend(0xFF)
	if rest = 0 
		return 
	end

	j = 1
	while j <= 6
		payloadTx[j] = 0
		j=j+1
	end

	mspRequestsSent = mspRequestsSent + 1

	payloadTx[1] = sportMspSeq + SPORT_MSP_VERSION
	sportMspSeq += 1
	sportMspSeq = sportMspSeq & 0x0F
	
	
	if mspTxIdx = 1 
		rem --- start flag only for id=1
		payloadTx[1] = payloadTx[1] + SPORT_MSP_STARTFLAG
	end

	i = 2
	while i <= 6
		rem --- payloadTx[2]=payload size
		payloadTx[i] = mspTxBuf[mspTxIdx]
		mspTxIdx = mspTxIdx + 1
		mspTxCRC ^= payloadTx[i]
		i = i + 1
			if mspTxIdx > t_size
				goto break1
			end
		end 

	break1:

	if i <= 6 
		payloadTx[i] = mspTxCRC  
		i = i + 1
		rem --- zero fill
		while i <= 6 
			payloadTx[i] = 0
			i = i + 1
		end 	
		gosub mspSendSport

		rem ---reset buffer
		j = 1
		while j < 32
			mspTxBuf[j] = 0
			j = j + 1
		end
		t_size = 0
		mspTxIdx = 1
		mspTxCRC = 0
		return
	end
 
	gosub mspSendSport
return

mspSendSport:
	dataId = 0
	dataId=payloadTx[1] + payloadTx[2] * 256
	value = 0
	value = payloadTx[3] + payloadTx[4] * 256 + payloadTx[5] * 65536 + 	payloadTx[6] * 16777216
	reti = sportTelemetrySend(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
	if reti > 0 	
		mspTxPk = mspTxPk + 1
	end
return

payload_zero:
	j = 1
	while j < 32
		payloadReq[j] = 0
		j += 1
	end
return


run:
	
	if Event = EVT_EXIT_BREAK
		goto done
	end
	
	if lastRunTS + UPDATE_FREQ < gettime()
		rssi = getvalue("RSSI")
		if rssi = 0
			goto break2
		end
		rssi_sent = (rssi + RSSI_OFFSET) * RSSI_MULT / RSSI_DIV
		if rssi_sent > 255
			rssi_sent = 255
		end
		
		
		
		p_size = 1
		payloadReq[1] = rssi_sent
		cmnd = MSP_SET_TX_INFO
		
		gosub mspSendRequest
		lastRunTS = gettime()
	end
	
	break2:
	
	if sysflags() & 0x1
		drawtext(0, 0, "RSSI:", 0)
		drawnumber(36, 0, rssi, 0)
		drawtext(42, 0, "sent", 0)
		drawnumber(80, 0, rssi_sent, 0)
		drawtext(0, 8, "mspTxPk:", 0)
		drawnumber(80, 8, mspTxPk, 0)
		drawtext(0, 16, "gettime():", 0)
		drawnumber(84, 16, gettime(), 0)
		drawtext(0, 24, "lastRunTS:", 0)
		drawnumber(84, 24, lastRunTS, 0)
	end
	
	gosub mspProcessTxQ
	
stop

done:
	finish
