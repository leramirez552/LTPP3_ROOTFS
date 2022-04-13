#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
info__input=${2}
menuOptions__input=${3}
readInputDialog1__input=${4}    #read dialog for 'Choose'
readInputDialog2__input=${5}    #read dialog for 'Add'
readInputDialog3__input=${6}    #read dialog for 'Del'
exportedEnvVarFpath__input=${7}   #e.g. exported_env_var.txt
cacheFpath__input=${8} #e.g. docker__gitlink.cache, docker__git_checkout.cache
outFpath__input=${9}    #e.g. docker_show_choose_add_del_from_cache.out
dockerfile_fpath__input=${10}    #e.g. repository:tag
argType__input=${11}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=0
    docker__cachedInput_arrIndex_max=0

    docker__line=${DOCKER__EMPTYSTRING}
    docker__lineNum=0
    docker__lineNum_base=0
    docker__lineNum_min=0
    docker__lineNum_min_bck=0
    docker__lineNum_max=0

    docker__table_index=0

    docker__dataFpath_numOfLines=0
    docker__fixed_numOfLines=0
    docker__info_numOfLines=0
    docker__menuOptions_numOfLines=0
    docker__menuTitle_numOfLines=0
    docker__readInputDialog1_numOfLines=0
    docker__readInputDialog2_numOfLines=0
    docker__readInputDialog3_numOfLines=0
    docker__subTot_numOfLines=0
    docker__tot1_numOfLines=0
    docker__tot2_numOfLines=0
    docker__tot3_numOfLines=0
    docker__tot_numOfLines=0

 
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__readInputDialog=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    docker__repositoryTag=${DOCKER__EMPTYSTRING}

    docker__flag_break_menuOption_handler=false
    docker__flag_turnPage_isAllowed=false
}

docker__remove_files__sub() {
    #Remove file if present
    if [[ -f ${outFpath__input} ]]; then
        rm ${outFpath__input}
    fi
}

docker__calc_numOfLines_of_inputArgs__sub() {
    #1. MENUTITLE / INFO / MENUOPTIONS / READINPUT DIALOGS / FIXED 
    #Get the number of lines for each object
    docker__menuTitle_numOfLines=`echo -e "${menuTitle__input}" | wc -l`
    docker__info_numOfLines=`echo -e "${info__input}" | wc -l`
    docker__menuOptions_numOfLines=`echo -e "${menuOptions__input}" | wc -l`
    docker__readInputDialog1_numOfLines=`echo -e "${readInputDialog1__input}" | wc -l`
    docker__readInputDialog2_numOfLines=`echo -e "${readInputDialog2__input}" | wc -l`
    docker__readInputDialog3_numOfLines=`echo -e "${readInputDialog3__input}" | wc -l`
    docker__fixed_numOfLines=${DOCKER__NUMOFLINES_6}    #allOther means: horizontal lines, empty string lines, prev-next line.

    #Calculate unchanged number of lines
    docker__subTot_numOfLines=$((docker__menuTitle_numOfLines + docker__info_numOfLines + docker__menuOptions_numOfLines + docker__fixed_numOfLines + DOCKER__TABLEROWS))

    #Calculate the total number of lines for 3 situations:
    #1. HASH (e.g. Choose)
    docker__tot1_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog1_numOfLines))
    #2. PLUS (e.g. Add)
    docker__tot2_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog2_numOfLines))
    #3. MINUS (e.g. Del)
    docker__tot3_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog3_numOfLines))

    #2. FILE (Initial)
    docker__dataFpath_numOfLines=`cat ${cacheFpath__input} | wc -l`
}

docker__prev_next_var_set__sub() {
    docker__prev_only_print="${DOCKER__ONESPACE_PREV}"

    docker__oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    docker__oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    docker__space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (docker__oneSpacePrev_len + docker__oneSpaceNext_len) - 1 ))
    docker__space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker__space_between_prev_and_next_len}"`
    docker__prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${docker__space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - docker__oneSpacePrev_len - 1 ))
    docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`
    docker__next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"
}

docker_show_mainMenu_handler__sub() {
    #Initialization
    docker__readInputDialog=${readInputDialog1__input}
    docker__lineNum_base=0
    docker__lineNum_min_bck=0
    docker__lineNum_min=0
    docker__lineNum_max=0
    docker__flag_turnPage_isAllowed=false

    #Update sequence-related values
    #1. docker__lineNum_base
    #2. docker__lineNum_min_bck
    #3. docker__lineNum_min
    #4. docker__lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__lineNum_base}" \
                        "${docker__lineNum_min}" \
                        "${DOCKER__TABLEROWS}" \
                        "${DOCKER__NEXT}"

    while true
    do
        #Check if 'docker__lineNum_min' has changed by comparing the current value with the backup'ed value.
        if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
            #Print a horizontal line
            echo -e "${DOCKER__HORIZONTALLINE}"
            #Show menu-title
            show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
            #Print a horizontal line
            echo -e "${DOCKER__HORIZONTALLINE}"

            #Show file-cotent
            docker__show_fileContent__sub

            #Move-down and clean line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show prev-next line
            docker__show_prev_next_handler__sub "${cacheFpath__input}"
            #Show line-number range in between prev and next
            docker__show_lineNumRange_between_prev_and_next__sub

            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
            #show location of the cache-file
            echo -e "${info__input}"
            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"

            #Print menu-options
            echo -e "${menuOptions__input}"
            
            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
        fi
        
        #Show choose dialog
        docker__menuOption_handler__sub
    done
}
docker__show_fileContent__sub() {
    #Show cursor
    cursor_hide__func

    #Initialization
    docker__lineNum=0
    docker__table_index=0
    local line_subst=${DOCKER__EMPTYSTRING}
    local line_print=${DOCKER__EMPTYSTRING}
    local webLink_isAccessible=false
    local match_isFound=false

#---List file-content
    while read -ra line
    do
        #increment line-number
        docker__lineNum=$((docker__lineNum + 1))

        #Show filename
        if [[ ${docker__lineNum} -ge ${docker__lineNum_min} ]]; then
            if [[ ! -z ${line} ]]; then
                #Increment table index-number
                docker__table_index=$((docker__table_index + 1))

                #Substitute 'http' with 'hxxp'
                #Remark:
                #   This substitution is required in order to eliminate the underlines for hyperlinks
                line_subst=`subst_string_with_another_string__func "${line}" "${SED__HTTP}" "${SED__HXXP}"`

                #Redefine 'docker__table_index' in case its '10'
                if [[ ${docker__table_index} -eq ${DOCKER__NUMOFMATCH_10} ]]; then
                    docker__table_index=${DOCKER__NUMOFMATCH_0}
                fi

                #Only do this check if 'argType__input = DOCKER__ENUM_DOCKER_ARG1'
                if [[ ${argType__input} == ${DOCKER__ENUM_DOCKER_ARG1}  ]]; then
                    #Check if web-link is reachable
                    webLink_isAccessible=`checkIf_webLink_isAccessible__func ${line} ${DOCKER__TIMEOUT_3}`

                    #Define and set 'line_colored'
                    if [[ ${webLink_isAccessible} == true ]]; then
                        line_subst=${DOCKER__FG_GREEN85}${DOCKER__STX}${line_subst}${DOCKER__NOCOLOR}
                    # else
                    #     line_subst=${DOCKER__FG_SOFTLIGHTRED}${DOCKER__STX}${line_subst}${DOCKER__NOCOLOR}
                    fi
                fi

                #Define and set 'line_print'
                if [[ ${docker__table_index} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                    line_print="${DOCKER__FOURSPACES}${docker__table_index}. ${line_subst}"
                else
                    line_print="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${DOCKER__LINENUM_1}${DOCKER__NOCOLOR}${docker__table_index}. ${line_subst}"
                fi

                #Check if 'exported_env_var.txt' exists
                if [[ -f ${exportedEnvVarFpath__input} ]]; then
                    #Get the repository:tag from 'dockerfile_fpath__input'
                    docker__repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

                    #Check if 'line' is found in 'exported_env_var.txt'                  
                    match_isFound=`checkForMatch_keyWord_within_file__func "${docker__repositoryTag}" "${line}" "${exportedEnvVarFpath__input}"`
                    if [[ ${match_isFound} == true ]]; then #match is found
                        #Append '(In-Use)' behind 'line_subst' value
                        line_print="${line_print}${DOCKER__ONESPACE}${DOCKER__CONFIGURED}"
                    fi
                fi

                #Print file-content with table index-number
                echo "${line_print}"
            fi
        fi

        #Break loop once the maximum allowed sequence number has been reached
        if [[ ${docker__lineNum} -eq ${docker__lineNum_max} ]]; then
            break
        fi
    done < ${cacheFpath__input}

#---Fill up table with Empty Lines (if needed)
    #This is necessary to fill up the table with 10 lines.
    while [[ ${docker__lineNum} -lt ${docker__lineNum_max} ]]
    do
        #increment line-number
        docker__lineNum=$((docker__lineNum + 1))

        #Print an Empty Line
        echo "${DOCKER__EMPTYSTRING}"
    done

    #Show cursor
    cursor_show__func
}

docker__show_prev_next_handler__sub() {
    #Check if the specified file contains less than or equal to 10 lines
    if [[ ${docker__dataFpath_numOfLines} -le ${DOCKER__NUMOFMATCH_10} ]]; then #less than 10 lines
        #Don't show anything
        echo -e "${EMPTYSTRING}"
    else    #file contains more than 10 lines
        if [[ ${docker__lineNum_min} -eq ${DOCKER__NUMOFMATCH_1} ]]; then   #range 1-10
            echo -e "${docker__next_only_print}"
        else    #all other ranges
            if [[ ${docker__lineNum_max} -gt ${docker__dataFpath_numOfLines} ]]; then   #range 10-20, 20-30, 30-40, etc.
                echo -e "${docker__prev_only_print}"
            else    #last range value (e.g. 40-50)
                echo -e "${docker__prev_spaces_next_print}"
            fi
        fi
    fi
}
docker__show_lineNumRange_between_prev_and_next__sub() {
    #Define the maximum range line-number
    #Remark:
    #   Whenever 'prev' or 'nexxt' is pressed, the maximum range line-number will also change.
    local lineNum_max=${docker__lineNum_max}
    
    #Check if 'docker__lineNum_max > docker__dataFpath_numOfLines'?
    if [[ ${docker__lineNum_max} -gt ${docker__dataFpath_numOfLines} ]]; then   #true
        #Reprep 'lineNum_range_msg', use 'docker__dataFpath_numOfLines' instead of 'docker__lineNum_max'
        lineNum_max=${docker__dataFpath_numOfLines}
    fi

    #Prepare the line-number range message
    local lineNum_range_msg="${DOCKER__FG_LIGHTGREY}${docker__lineNum_min}${DOCKER__NOCOLOR} "
    lineNum_range_msg+="to ${DOCKER__FG_LIGHTGREY}${lineNum_max}${DOCKER__NOCOLOR} "
    lineNum_range_msg+="(${DOCKER__FG_SOFTLIGHTRED}${docker__dataFpath_numOfLines}${DOCKER__NOCOLOR})"

    #Caclulate the length of 'lineNum_range_msg' without regEx
    local lineNum_range_msg_wo_regEx_len=`get_stringlen_wo_regEx__func "${lineNum_range_msg}"`

    #Determine the start-position of where to place 'lineNum_range_msg'
    local lineNum_range_msg_startPos=$(( (DOCKER__TABLEWIDTH/2) - (lineNum_range_msg_wo_regEx_len/2) ))

    #Move cursor to start-position 'lineNum_range_msg_startPos'
    tput cuu1 && tput cuf ${lineNum_range_msg_startPos}

    #Print 'lineNum_range_msg'
    echo -e "${lineNum_range_msg}"
}

docker__seqNum_handler__sub() {
    #This subroutine will update the 'global' variables:
    #1. docker__lineNum_base
    #2. docker__lineNum_min_bck
    #3. docker__lineNum_min
    #4. docker__lineNum_max
    #5. docker__flag_turnPage_isAllowed

    #Input args
    local seqNum_base__input=${1}
    local seqNum_min__input=${2}   #current minimum value
    local seqNum_range__input=${3} #max number of items allowed to be shown in table
    local turnPageDirection__input=${4}

    #Backup current 'docker__lineNum_min'
    docker__lineNum_min_bck=${seqNum_min__input}

    #Get the minimum value
    if [[ ${seqNum_min__input} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        docker__lineNum_min=${DOCKER__NUMOFMATCH_1}
    else
        case "${turnPageDirection__input}" in
            ${DOCKER__PREV})
                #Increment the base value (e.g. 50, 40, 30, etc.)
                docker__lineNum_base=$((seqNum_base__input - seqNum_range__input))

                #Decrement the minimum value
                docker__lineNum_min=$((seqNum_min__input - seqNum_range__input))

                #Check if 'docker__lineNum_min' is less than 'DOCKER__NUMOFMATCH_1'.
                if [[ ${docker__lineNum_min} -lt ${DOCKER__NUMOFMATCH_1} ]]; then
                    #Set 'docker__lineNum_base' equal to the input value 'DOCKER__NUMOFMATCH_1
                    docker__lineNum_base=${DOCKER__NUMOFMATCH_0}

                    #Set 'docker__lineNum_min' equal to the input value 'DOCKER__NUMOFMATCH_1'
                    docker__lineNum_min=${DOCKER__NUMOFMATCH_1}
                fi
                ;;
            ${DOCKER__NEXT})
                #Increment the base value (e.g. 0, 10, 20, 30, et.)
                docker__lineNum_base=$((seqNum_base__input + seqNum_range__input))

                #Increment the minimum value
                docker__lineNum_min=$((seqNum_min__input + seqNum_range__input))

                #Check if 'docker__seqNum_mi > docker__dataFpath_numOfLines'.
                if [[ ${docker__lineNum_min} -gt ${docker__dataFpath_numOfLines} ]]; then
                    #Set 'docker__lineNum_base' equal to the input value 'seqNum_base__input
                    docker__lineNum_base=${seqNum_base__input}

                    #Set 'docker__lineNum_min' equal to the input value 'seqNum_min__input'
                    docker__lineNum_min=${seqNum_min__input}
                fi
                ;;
        esac
    fi

    #Get the maximum value
    docker__lineNum_max=$((docker__lineNum_min + seqNum_range__input - 1))
    
    #Set 'docker__flag_turnPage_isAllowed'
    #Remark:
    #   Compare 'docker__lineNum_min' with 'docker__lineNum_min_bck'. 
    #   1. Both values are not equal, then set 'docker__flag_turnPage_isAllowed = true'.
    #   2. Both values are the same, then set 'docker__flag_turnPage_isAllowed = false'.
    if [[ ${docker__lineNum_min} -ne ${docker__lineNum_min_bck} ]]; then
        docker__flag_turnPage_isAllowed=true
    else
        docker__flag_turnPage_isAllowed=false
    fi
}

docker__menuOption_handler__sub() {
    while true
    do
        #Show echo-message
        echo "${docker__readInputDialog}${docker__totInput}" 

        moveUp_oneLine_then_moveRight__func "${docker__readInputDialog}" "${docker__totInput}"

        #Show read-input dialog
        read -N1 -rs docker__keyInput

        #Handle docker__keyInput
        case "${docker__keyInput}" in
            ${DOCKER__BACKSPACE})
                docker__backspace_handler__sub
                ;;
            ${DOCKER__ENTER})
                docker__enter_handler__sub
                ;;
            ${DOCKER__ESCAPEKEY})
                docker__escapekey_flush_handler__sub
                ;;
            ${DOCKER__TAB})
                docker__tab_handler__Sub    
                ;;
            ${DOCKER__HASH})
                docker__hash_handler__sub
                ;;
            ${DOCKER__PLUS})
                docker__plus_handler__sub
                ;;
            ${DOCKER__MINUS})
                docker__minus_handler__sub
                ;;
            ${DOCKER__ESCAPE_HOOKLEFT})  
                docker__prev_handler__sub

                break
                ;;
            ${DOCKER__ESCAPE_HOOKRIGHT})  
                docker__next_handler__sub

                break
                ;;
            ${DOCKER__CARET})  
                docker__exit_handler__sub
                ;;
            *)
                docker__any_handler__sub
                ;;
        esac

        #Check if 'docker__flag_break_menuOption_handler = true'.
        #If true, then break this loop.
        if [[ ${docker__flag_break_menuOption_handler} == true ]]; then
            #Reset flag to 'false'
            docker__flag_break_menuOption_handler=false

            #Move down and clean
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Break loop
            break
        fi
    done
}

docker__backspace_handler__sub() {
    #Define variables
    local totInput_len=0

    #Get string length
    totInput_len=${#docker__totInput}

    #Check if the length is greater than 0
    #REMARK:
    #	If FALSE, then do not execute this part, otherwise...
    #	...the following ERROR would occur:
    #	" totInput_len: substring expression < 0"
    if [[ ${totInput_len} -gt 0 ]]; then	#length MUST be greater than 0
        #Substract by 1
        totInput_len=$((totInput_len-1))				

        #Substract 1 TRAILING character
        docker__totInput=${docker__totInput:0:totInput_len}
    else
        docker__totInput=${EMPTYSTRING}
    fi

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
}

docker__enter_handler__sub() {
    #Process 'docker__keyInput' based on 'docker__readInputDialog'
    case "${docker__readInputDialog}" in
        ${readInputDialog2__input})
            docker__enter_add_handler__sub
            ;;
        ${readInputDialog3__input})
            echo "ENTER:::readInputDialog3__input::: In progress"
            ;;
    esac

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func     
}

docker__enter_add_handler__sub() {
    #Check if 'docker__totInput' is an Empty String?
    if [[ -z ${docker__totInput} ]]; then   #true
        return
    fi

    #Check if the clear-command ';c' was executed
    local totInput_tmp=`get_endResult_ofString_with_semiColonChar__func "${docker__totInput}"`
    case "${totInput_tmp}" in
        ${DOCKER__EMPTYSTRING})
            docker__totInput=${DOCKER__EMPTYSTRING}

            return
            ;;
        *)
            #Check if 'docker__totInput' is already added to 'cacheFpath__input'?
            local isFound=`checkForMatch_keyWord_within_file__func "${docker__totInput}" "${DOCKER__EMPTYSTRING}" "${cacheFpath__input}"`
            if [[ ${isFound} == true ]]; then
                local ERRMSG_GITLINK_ALREADY_ADDED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: (git-)link already added"
                show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_GITLINK_ALREADY_ADDED}" \
                            "${DOCKER__NUMOFLINES_2}" \
                            "${DOCKER__TIMEOUT_10}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_1}"

                #Move-up and clean
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

                return
            fi

            #Check current number of entries
            if [[ ${docker__dataFpath_numOfLines} -ge ${DOCKER__GIT_CACHE_MAX} ]]; then
                local ERRMSG_MAX_NUMOFENTRIES_REACHED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: maximum number of entries reached "
                 ERRMSG_MAX_NUMOFENTRIES_REACHED+="(${DOCKER__FG_SOFTLIGHTRED}${docker__dataFpath_numOfLines}${DOCKER__NOCOLOR})\n"
                ERRMSG_MAX_NUMOFENTRIES_REACHED+="***${DOCKER__FG_YELLOW}ADVICE${DOCKER__NOCOLOR}: please remove unused entries"
            
                show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_MAX_NUMOFENTRIES_REACHED}" \
                            "${DOCKER__NUMOFLINES_2}" \
                            "${DOCKER__TIMEOUT_10}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_1}"

                #Move-up and clean
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"

                return
            fi

            #Only do this check if 'argType__input = DOCKER__ENUM_DOCKER_ARG1'
            if [[ ${argType__input} == ${DOCKER__ENUM_DOCKER_ARG1} ]]; then
                local ERRMSG_CHOSEN_WEBLINK_IS_NOTACCESSIBLE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: (git-)link is NOT accessable"

                #Check if 'docker__totInput' is accessible
                webLink_isAccessible=`checkIf_webLink_isAccessible__func ${docker__totInput} ${DOCKER__TIMEOUT_3}`
                if [[ ${webLink_isAccessible} == false ]]; then #not accessible
                    #Show error message
                    show_msg_wo_menuTitle_w_confirmation__func "${ERRMSG_CHOSEN_WEBLINK_IS_NOTACCESSIBLE}" \
                            "${DOCKER__NUMOFLINES_2}" \
                            "${DOCKER__TIMEOUT_10}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_1}"

                    #Move-up and clean
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

                    #If 'extern__ret = n', then exit function
                    if [[ ${extern__ret} == "${DOCKER__N}" ]]; then
                        return
                    fi
                fi
            fi

            #Insert 'line' at the top of the file.
            insert_string_into_file__func "${docker__totInput}" "${DOCKER__LINENUM_1}" "${cacheFpath__input}"

            #Update 'docker__dataFpath_numOfLines'
            docker__dataFpath_numOfLines=`cat ${cacheFpath__input} | wc -l`

            #Write to file"
            write_data_to_file__func "${docker__totInput}" "${outFpath__input}"

            #Update 'exported_env_var.txt'
            local docker_arg1=${DOCKER__EMPTYSTRING}
            local docker_arg2=${DOCKER__EMPTYSTRING}
            if [[ ${argType__input} == ${DOCKER__ENUM_DOCKER_ARG1} ]]; then
                docker_arg1=${docker__totInput}
            else    #argType__input = DOCKER__ENUM_DOCKER_ARG2
                docker_arg2=${docker__totInput}
            fi
            update_exported_env_var__func "${docker_arg1}" \
                        "${docker_arg2}" \
                        "${dockerfile_fpath__input}" \
                        "${exportedEnvVarFpath__input}"

            #Reset 'docker__totInput'
            docker__totInput=${DOCKER__EMPTYSTRING}

            #Break the loop of subroutine 'docker__menuOption_handler__sub'
            docker__flag_break_menuOption_handler=true
            ;;
    esac
}
docker__enter_add_update_cachePath__sub() {
    #Check if 'docker__totInput' is already added to 'cacheFpath__input'?
    local isFound=`checkForMatch_keyWord_within_file__func "${docker__totInput}" "${DOCKER__EMPTYSTRING}" "${cacheFpath__input}"`
    if [[ ${isFound} == true ]]; then
        return
    fi

    #Insert 'line' at the top of the file.
    insert_string_into_file__func "${docker__totInput}" "${DOCKER__LINENUM_1}" "${cacheFpath__input}"
}

docker__escapekey_flush_handler__sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func      

    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
}

docker__tab_handler__Sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func     
}

docker__hash_handler__sub() {
    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from '+' to '#'
    if [[ ${docker__readInputDialog} != ${readInputDialog1__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}
    fi

    #Set 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog1__input}

    #Move-up and clean lines
    moveToBeginning_and_cleanLine__func
}

docker__plus_handler__sub() {
    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from '#' to '+'
    if [[ ${docker__readInputDialog} != ${readInputDialog2__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}
    fi

    #Set 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog2__input}

    #Move-up and clean lines
    moveToBeginning_and_cleanLine__func
}

docker__minus_handler__sub() {
    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from '+' to '-'
    if [[ ${docker__readInputDialog} != ${readInputDialog3__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}
    fi

    #Set 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog3__input}

    #Move-up and clean lines
    moveToBeginning_and_cleanLine__func
    
    echo "docker__minus_handler__sub::: IN PROGRESS..."
}

docker__next_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Update sequence-related values
    #1. docker__lineNum_base
    #2. docker__lineNum_min_bck
    #3. docker__lineNum_min
    #4. docker__lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__lineNum_base}" \
                        "${docker__lineNum_min}" \
                        "${DOCKER__TABLEROWS}" \
                        "${DOCKER__NEXT}"

    #Select the appropriate 'number of lines'
    if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
        case "${docker__readInputDialog}" in
            ${readInputDialog1__input})    #hash (e.g. Choose)
                docker__tot_numOfLines=${docker__tot1_numOfLines}
                ;;
            ${readInputDialog2__input})    #hash (e.g. Add)
                docker__tot_numOfLines=${docker__tot2_numOfLines}
                ;;
            ${readInputDialog3__input})    #hash (e.g. Del)
                docker__tot_numOfLines=${docker__tot3_numOfLines}
                ;;
        esac

        moveUp_and_cleanLines__func "${docker__tot_numOfLines}"
    else
        moveToBeginning_and_cleanLine__func   
    fi

    #Show cursor
    cursor_show__func
}

docker__prev_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Update sequence-related values
    #1. docker__lineNum_base
    #2. docker__lineNum_min_bck
    #3. docker__lineNum_min
    #4. docker__lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__lineNum_base}" \
                        "${docker__lineNum_min}" \
                        "${DOCKER__TABLEROWS}" \
                        "${DOCKER__PREV}"

    #Select the appropriate 'number of lines'
    if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
        case "${docker__readInputDialog}" in
            ${readInputDialog1__input})    #hash (e.g. Choose)
                docker__tot_numOfLines=${docker__tot1_numOfLines}
                ;;
            ${readInputDialog2__input})    #hash (e.g. Choose)
                docker__tot_numOfLines=${docker__tot2_numOfLines}
                ;;
            ${readInputDialog3__input})    #hash (e.g. Choose)
                docker__tot_numOfLines=${docker__tot3_numOfLines}
                ;;
        esac

        moveUp_and_cleanLines__func "${docker__tot_numOfLines}"
    else
        #Clean and Move to the beginning of line
        moveToBeginning_and_cleanLine__func
    fi

    #Show cursor
    cursor_show__func
}

docker__exit_handler__sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func

    #Show last key-input
    echo "${readInputDialog1__input}${docker__keyInput}" 

    #Exit this file
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}

docker__any_handler__sub() {
    #Number of Lines of file 'cacheFpath__input'
    if [[ ${docker__dataFpath_numOfLines} -ne ${DOCKER__NUMOFMATCH_0} ]]; then    #contains no data
        #Process 'docker__keyInput' based on 'docker__readInputDialog'
        case "${docker__readInputDialog}" in
            ${readInputDialog1__input})
                docker__any_choose_handler__sub
                ;;
            ${readInputDialog2__input})
                docker__any_add_handler__sub
                ;;
            ${readInputDialog3__input})

                ;;
        esac
    fi

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}

docker__any_choose_handler__sub() {
    #Check if 'docker__keyInput' is a number
    local isNumeric=`isNumeric__func ${docker__keyInput}`
    case "${isNumeric}" in
        false)
            return
            ;;
        true)    
            #Move selected item to the top of 'cacheFpath__input'
            #Output:
            #   docker__line
            docker__selItem_moveToTop_of_cacheFpath__sub
         
            #Write to output file"
            write_data_to_file__func "${docker__line}" "${outFpath__input}"

            #Update 'exported_env_var.txt'
            local docker_arg1=${DOCKER__EMPTYSTRING}
            local docker_arg2=${DOCKER__EMPTYSTRING}
            if [[ ${argType__input} == ${DOCKER__ENUM_DOCKER_ARG1} ]]; then
                docker_arg1=${docker__line}
            else    #argType__input = DOCKER__ENUM_DOCKER_ARG2
                docker_arg2=${docker__line}
            fi
            update_exported_env_var__func "${docker_arg1}" \
                        "${docker_arg2}" \
                        "${dockerfile_fpath__input}" \
                        "${exportedEnvVarFpath__input}"

            #Break the loop of subroutine 'docker__menuOption_handler__sub'
            docker__flag_break_menuOption_handler=true
            ;;
    esac
}
docker__selItem_moveToTop_of_cacheFpath__sub() {
    #Define and set the relative linenumber 'lineNum_rel'
    local lineNum_rel=${docker__keyInput}

    #IMPORTANT: set 'lineNum_rel' to 'DOCKER__TABLEROWS' if 'lineNum_rel = 0'
    if [[ ${lineNum_rel} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        lineNum_rel=${DOCKER__TABLEROWS}
    fi

    #Get the absolute line-number
    local lineNum_abs=$((docker__lineNum_base + lineNum_rel))

    #Retrieve 'string' from file based on the specified 'lineNum__input'
    docker__line=`retrieve_line_from_file__func "${lineNum_abs}" "${cacheFpath__input}"`

    #Delete line specified by 'lineNum_abs'
    delete_lineNum_from_file__func "${lineNum_abs}" "${cacheFpath__input}"

    #Insert 'line' at the top of the file.
    insert_string_into_file__func "${docker__line}" "${DOCKER__LINENUM_1}" "${cacheFpath__input}"
}

docker__any_add_handler__sub() {
    #wait for another 0.5 seconds to capture additional characters.
    #Remark:
    #   This part has been implemented just in case long text has been copied/pasted.
    read -rs -t0.01 docker__keyInput_add

    #Append 'docker__keyInput_add' to 'docker__keyInput'
    docker__keyInput="${docker__keyInput}${docker__keyInput_add}"

    #Append key-input
    docker__totInput="${docker__totInput}${docker__keyInput}"

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}





#---NOT IN USE YET
docker__escapekey_handler__sub() {
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    if [[ "$tmp" == "[" ]]; then
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn1 -t 0.1 tmp

        case "$tmp" in
            "A")
                arrow_direction=${DOCKER__ARROWUP}
                ;;
            "B")
                arrow_direction=${DOCKER__ARROWDOWN}
                ;;
        esac
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1

    #*********************************************************
    #This part MUST be executed after the 'Arrow-key handling'
    #*********************************************************
    if [[ ${arrow_direction} == ${DOCKER__ARROWUP} ]]; then
        if [[ ${docker__cachedInput_arrIndex} -eq 0 ]]; then    #index is already leveled to 0
            docker__cachedInput_arrIndex=${docker__cachedInput_arrIndex_max}    #set index to the max. value
        else    #for all other indexes
            docker__cachedInput_arrIndex=$((docker__cachedInput_arrIndex-1))
        fi
    else    #arrow_direction = DOCKER__ARROWDOWN
        if [[ ${docker__cachedInput_arrIndex} -eq ${docker__cachedInput_arrIndex_max} ]]; then  #index is already maxed out
            docker__cachedInput_arrIndex=0
        else    #for all other indexes
            docker__cachedInput_arrIndex=$((docker__cachedInput_arrIndex+1))
        fi
    fi

    #Update variable
    docker__totInput=${docker__cachedInput_arr[docker__cachedInput_arrIndex]}

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
}

#---NOT IN USE YET





#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__remove_files__sub

    docker__calc_numOfLines_of_inputArgs__sub

    docker__prev_next_var_set__sub

    docker_show_mainMenu_handler__sub
}



#---EXECUTE
main_sub