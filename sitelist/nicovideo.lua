
---[[by lostangel 20100918]]
--[[edit lostangel 20110216 add autologin]]
--[[edit lostangel 20110402 for subxml return struct]]

require "luascript/lib/lalib"

local nico_sublice_num = 2000; -- change this to set how many comments you will download for one video.

--[[parse single nico url]]
function getTaskAttribute_nico ( str_url, str_tmpfile , pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '��ʼ����..');
	end
	local int_acfpv = getACFPV ( str_url );

	--[[check login]]
	if IsAutoLogin == SUCCESS then
		local loginstate = Login_Nico ( str_tmpfile );
		if loginstate == FAILURE then
			return;
		end
	end

	-------[[read flv id start]]

	local _, _, str_id = string.find(str_url, "watch/([^%.]+)$"--[["watch/([sn]m[^%.]+)$"]]);--"/id_([^\.]+)\./");
	if str_id==nil then
		return;
	end

	local istwnico = 0;
	if string.find(str_url, "http://tw.nicovideo.jp", 1, true) ~= nil then
		istwnico = 1;
	end

	--get descriptor
	local re = dlFile(str_tmpfile, str_url);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '�Ѷ�ȡԭʼҳ�棬���ڷ���...');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	end

	--readin descriptor
	local str_line = readUntilFromUTF8(file, "<title>");
	local str_title_line = readIntoUntilFromUTF8(file, str_line, "</title>");
	local str_title = getMedText(str_title_line, "<title>", "</title>");

	local str_descriptor = str_title;


	--if is twnico, should readin vid
	local str_tw_vid = nil;
	if istwnico==1 then
		str_line = readUntilFromUTF8(file, "var Video");
		--dbgMessage(str_line);
		local str_vid_line = readIntoUntilFromUTF8(file, str_line, "v:");
		--dbgMessage(str_vid_line);
		str_tw_vid = getMedText(str_vid_line, "'", "'");
		--dbgMessage(str_tw_vid);
	end

	--get descriptor end.close file
	io.close(file);


	--parse url
	if istwnico==1 then
		if str_tw_vid == nil then
			local file = io.open(str_tmpfile, "r");
			if file==nil
			then
				if pDlg~=nil then
					sShowMessage(pDlg, '��ȡԭʼҳ�����');
				end
				return;
			end
			str_line = readUntilFromUTF8(file, "Ո��Ҫ�̕r�g���B�m���M�뱾�Wվ");
			dbgMessage(str_line);
			io.close(file);
			return;
		end
		local str_getflv_url = "http://tw.nicovideo.jp/api/getflv?v="..str_tw_vid;
		re = dlFile(str_tmpfile, str_getflv_url);
	else
		local str_getflv_url = "http://flapi.nicovideo.jp/api/getflv";
		--local str_post_data = string.format("v=%s&ts=%s&as=1", str_id, tostring(os.time()));
		local str_post_data = string.format("v=%s&as=1", str_id);
		re = postdlFile(str_tmpfile, str_getflv_url, str_post_data, "Referer: http\r\nContent-type: application/x-www-form-urlencoded");
		--dbgMessage("post ok.");
	end
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡ��תҳ�����');
		end
		return;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '�Ѷ�ȡ��תҳ�棬���ڷ���...');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡ��תҳ�����');
		end
		return;
	end
	str_line = file:read("*l");
	local str_threadid = getMedText(str_line, "thread_id=", "&");
	local str_real_url = decodeUrl(getMedText(str_line, "url=", "&"));
	local str_sub_url = decodeUrl(getMedText(str_line, "ms=", "&"));
	local str_userid = getMedText(str_line, "user_id=", "&");
	--dbgMessage(str_line);
	local str_needskey = getMedText(str_line, "needs_key=", "&");
	if str_needskey == nil then
		str_needskey = "0";
	end

	--dbgMessage(str_real_url);
	--dbgMessage(str_sub_url);

	if str_threadid == nil or str_real_url == nil or str_sub_url == nil or str_userid == nil then
		io.close(file);
		return;
	end
	--dbgMessage(str_needskey);

	-- parse ok close file
	io.close(file);


	local str_threadkey = nil;
	local str_force_184 = nil;
	--getthreadkey
	if str_needskey == "1" then
		local str_getthreadkeyurl = "http://flapi.nicovideo.jp/api/getthreadkey?thread="..str_threadid;
		local re = dlFile(str_tmpfile, str_getthreadkeyurl);
		if re~=0
		then
			if pDlg~=nil then
				sShowMessage(pDlg, '��ȡԭʼҳ�����');
			end
			return;
		else
			if pDlg~=nil then
				sShowMessage(pDlg, '�Ѷ�ȡԭʼҳ�棬���ڷ���...');
			end
		end

		local file = io.open(str_tmpfile, "r");
		if file==nil
		then
			if pDlg~=nil then
				sShowMessage(pDlg, '��ȡԭʼҳ�����');
			end
			return;
		end

		local str_line_threadkey = file:read("*l");
		str_threadkey = getMedText(str_line_threadkey, "threadkey=", "&");
		str_force_184 = getMedText(str_line_threadkey, "force_184=", "&");
		if str_force_184==nil and string.find(str_line_threadkey, "force_184=", 1, true)~=nil
		then
			local int_force184index = string.find(str_line_threadkey, "force_184=", 1, true) + string.len("force_184=");
			str_force_184 = string.sub(str_line_threadkey, int_force184index, int_force184index+1);
		end

		io.close(file);
	end



	--dl sub xml
	str_getflv_url = str_sub_url;
	if str_needskey == "1" then
		str_post_data = string.format('<packet><thread thread="%s" version="20061206" res_from="-%d" user_id="%s" threadkey="%s" force_184="%s"/><thread thread="%s" version="20061206" res_from="-%d" threadkey="%s" force_184="%s" fork="1" click_revision="-1"/></packet>'
		, str_threadid, nico_sublice_num, str_userid, str_threadkey, str_force_184
		, str_threadid, nico_sublice_num, str_threadkey, str_force_184);
	else
		str_post_data = string.format('<packet><thread thread="%s" version="20061206" res_from="-%d" user_id="%s"/><thread thread="%s" version="20061206" res_from="-%d" fork="1" click_revision="-1"/></packet>'
		, str_threadid, nico_sublice_num, str_userid
		, str_threadid, nico_sublice_num);
	end
	--dbgMessage(str_post_data);
	re = postdlFile(str_tmpfile, str_getflv_url, str_post_data, "Content-type: text/xml");
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡ��Ļ�ļ�����');
		end
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '�Ѷ�ȡ��Ļ�ļ�');
		end
	end

	-- create realurls.
	local tbl_realurls = {};
	tbl_realurls["0"] = str_real_url;
	local int_realurlnum = 1;



	--local int_realurlnum, tbl_realurls = getRealUrls_QQ(str_id, str_tmpfile, pDlg);




	if pDlg~=nil then
		sShowMessage(pDlg, '��ɽ���..');
	end

	local tbl_subxmlurls = {};
	tbl_subxmlurls["0"] = "file:///" .. str_tmpfile;

	local tbl_ta = {};
	tbl_ta["acfpv"] = int_acfpv;
	tbl_ta["descriptor"] = str_id.." - "..str_descriptor;
	tbl_ta["subxmlurl"] = tbl_subxmlurls;--str_subxmlurl;
	tbl_ta["realurlnum"] = int_realurlnum;
	tbl_ta["realurls"] = tbl_realurls;
	tbl_ta["oriurl"] = str_url;
	--dbgMessage(tbl_realurls["0"]);
	--dbgMessage(tbl_ta["realurls"]["0"]);
	--dbgMessage(string.format("%d videos.", int_realurlnum));

	local tbl_resig = {};
	tbl_resig[string.format("%d",0)] = tbl_ta;
	return tbl_resig;
end

