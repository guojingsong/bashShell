#!/bin/bash
#########################################################################
# システムＩＤ       ： 
# システム名称       ： 
# ＩＤ               ： 
# 処理概要          ： HULFTでのファイル送信を行う
# 処理パターン       :（1：ファイル名固定、2：ディレクトリのみ指定、3：ファイル内正規表現）
# 送信元ディレクトリ :送信元のディレクトリを指定する
# 送信元ファイル     :送信元ファイルを指定する
# 送信先ディレクトリ :送信先のディレクトリを指定する
# 必須チェックフラグ :true：処理対象ファイルが0件だった時に異常終了にする。true以外：処理対象ファイル0件の時正常終了する
# リターンコード     ： 0：正常終了  1：異常終了
#
# 改定履歴
# 年月日    区分 担当者    内容
# -------- ---- -------- --------------------------------------
# 20230911 新規 Cube劉    新規作成
#
#########################################################################
# ASTERIA共通シェルを読み込む
function joblog
{
  echo "[`date \"+%Y-%m-%d %H:%M:%S,%3N\"`][$1][${JOBID}][${STEPID}][shell][][][$2]" | tee -a ${LOGFILE}
}
#------------------------------------------------------------------------
# ジョブ内設定
#------------------------------------------------------------------------
ProgramID=hulft-send.sh

#処理パターン
ProcessPattern=$1

errCode=""

STEPID=0
#------------------------------------------------------------------------
# 1	開始処理
#------------------------------------------------------------------------
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "JOB-START"
echo "********************************************************************"
STEPID=1
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "STEP${STEPID}-START"
echo "********************************************************************"
# 開始ログを出力する
joblog "ID調整中1" "HULFT送信処理を開始しました" "${ProcessPattern}","${SendSourceDirectory}","${SourceFile}","${SendDestDirectory}"
#------------------------------------------------------------------------
# 2	引数.処理パターン チェック
#------------------------------------------------------------------------
# 引数.処理パターンが1,2,3に該当しない場合
for param in "$@"; do
	shift
	case "$param" in
		"-pr")  
      #処理パターン
      ProcessPattern=$1
      ;;
		"-se")
      #送信元ディレクトリ    
      SendSourceDirectory=$1
      ;;
		"-so") 
      #送信元ファイル    
      SourceFile=$1
      ;;
		"-sd") 
      #送信先ディレクトリ    
      SendDestDirectory=$1
      ;;
		"-ch") 
      #必須チェックフラグ     
      CheckFlag=$1
      ;;        
	esac
done
echo "********************************************************************"
echo "処理パターン="$ProcessPattern
echo "送信元ディレクトリ="$SendSourceDirectory
echo "送信元ファイル="$SourceFile
echo "送信先ディレクトリ="$SendDestDirectory
echo "必須チェックフラグ="$CheckFlag
echo "********************************************************************"
if [ ! "${ProcessPattern}" == 1 ] && [ ! "${ProcessPattern}" == 2 ] && [ ! "${ProcessPattern}" == 3 ] ;
then
  # ログを出力して終了コード「1」で処理を終了する
  joblog "ID調整中2" "引数が不正です、HULFT送信処理を終了しました"
  exit 1  
fi
#------------------------------------------------------------------------
# 3	引数.処理パターンに応じて分岐処理を行う
#------------------------------------------------------------------------
# 
	# 引数.処理パターン=1の場合
  if [ "${ProcessPattern}" == 1 ];
  then
    #引数の個数が4個ではないまたは1つ以上が空欄の場合
    #if [ $# -lt 4 ];
    if [ "${SendSourceDirectory}" == "" ] || [ "${SourceFile}" == "" ] ;      
    then
      joblog "ID調整中3" "引数が不正です、HULFT送信処理を終了しました"  
      exit 1
    fi
    # 引数2(送信元ディレクトリ)と引数3(送信元ファイル)で指定されるファイルが存在しない場合、
    if [ ! -e ${SendSourceDirectory}${SourceFile} ];
    then
      joblog "ID調整中5" "送信元ファイルが存在しません、HULFT送信処理を終了しました"  
      if [ "${CheckFlag}" == "true" ];
      then
        echo "exit 1"
        exit 1
      else
        echo "exit 0"      
        exit 0      
      fi
    fi
  fi  																																																				
	# 引数.処理パターン=2の場合
  if [ "${ProcessPattern}" == 2 ];
  then
    #引数の個数が3個ではないまたは1つ以上が空欄の場合
    #if [ $# -lt 3 ];
    if [ "${SendSourceDirectory}" == "" ];      
    then
      joblog "ID調整中6" "引数が不正です、HULFT送信処理を終了しました"  
      exit 1
    fi
    # 引数2(送信元ディレクトリ)と引数3(送信元ファイル)で指定されるファイルが存在しない場合、
    if [ -e ${SendSourceDirectory} ]; 
    then
      Filelist=`ls ${SendSourceDirectory} `
    else
      Filelist=""
    fi
    if [ "${Filelist}" == "" ];    
    then
      joblog "ID調整中8" "送信元ファイルが存在しません、HULFT送信処理を終了しました"  
      if [ "${CheckFlag}" == "true" ];
      then
        echo "exit 1"
        exit 1
      else
        echo "exit 0"      
        exit 0      
      fi
    fi
  fi 
	# 引数.処理パターン=3の場合		
  if [ "${ProcessPattern}" == 3 ];
  then
    #引数の個数が3個ではないまたは1つ以上が空欄の場合
    #if [ $# -lt 4 ];
    if [ "${SendSourceDirectory}" == "" ];          
    then
      joblog "ID調整中9" "引数が不正です、HULFT送信処理を終了しました"  
      exit 1
    fi
    # 引数2(送信元ディレクトリ)と引数3(送信元ファイル)で指定されるファイルが存在しない場合、
    if [ -e ${SendSourceDirectory} ]; 
    then
      Filelist=`ls ${SendSourceDirectory} |  ls |  awk  '/'${SourceFile}'/{ print $0 }'`
    else
      Filelist=""
    fi
    if [ "${Filelist}" == "" ];
    then
      joblog "ID調整中10" "送信元ファイルが存在しません、HULFT送信処理を終了しました"  
      if [ "${CheckFlag}" == "true" ];
      then
        echo "exit 1"
        exit 1
      else
        echo "exit 0"      
        exit 0      
      fi
    fi
  fi 
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "STEP${STEPID}-END"
echo "********************************************************************"  
STEPID=2  
#------------------------------------------------------------------------
# 4	コマンド「utlsend」で送信処理を行う
#------------------------------------------------------------------------
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "STEP${STEPID}-START"
echo "********************************************************************"
for flist in $Filelist; do
  sendPath=${SendSourceDirectory}"/"${flist} 
  #echo $ProgramID `date '+%y/%m/%d %H:%M:%S'[` ${sendPath}"]で送信処理を行う"
  #${HULFTPATH}\utlsend -f ${sendPath} -sync
  echo `ls "$sendPath"`
  #echo "ERR=["$errCode]
done
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "STEP${STEPID}-END"
echo "********************************************************************"
#------------------------------------------------------------------------
# 5 処理終了
#------------------------------------------------------------------------
echo "********************************************************************"
echo $ProgramID `date '+%y/%m/%d %H:%M:%S'` "JOB-END"
echo "********************************************************************"
  if [ ! "${errCode}" == "" ];
  then
    joblog "ID調整中" "一部ファイルの送信が失敗しました、HULFT送信処理を終了しました"
    exit 1    
  else
    joblog "ID調整中" "HULFT送信処理を終了しました"
    exit 0
  fi
