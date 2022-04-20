#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
exp_env_var_type__input=${1}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                               ${DOCKER__NOCOLOR}"
}

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="Select a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARK="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}NOTE: only files containing pattern '${DOCKER__CONTAINER_ENV1}'...\n"
    DOCKER__DIRLIST_REMARK+="${DOCKER__TENSPACES}...and '${DOCKER__CONTAINER_ENV2}' are shown${DOCKER__NOCOLOR}"
	DOCKER__DIRLIST_READ_DIALOG="Choose a file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"

    DOCKER__LINK_MENUTITLE="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del env-variable ${DOCKER__FG_GREEN41}Link${DOCKER__NOCOLOR}"
    DOCKER__LINK_LOCATION_INFO_MSG="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__LINK_MENUOPTIONS_MSG="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__LINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__LINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__LINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__LINK_CHOOSE_LINK="Choose link: "
    DOCKER__LINK_ADD_LINK="Add link (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__LINK_DELETE_LINK="Del link: "

    DOCKER__CHECKOUT_MENUTITLE="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del env-variable ${DOCKER__FG_GREEN119}Checkout${DOCKER__NOCOLOR}"
    DOCKER__CHECKOUT_LOCATION_INFO_MSG="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__CHECKOUT_MENUOPTIONS_MSG="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__CHECKOUT_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__CHECKOUT_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__CHECKOUT_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__CHECKOUT_CHOOSE_CHECKOUT="Choose checkout: "
    DOCKER__CHECKOUT_ADD_CHECKOUT="Add checkout (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__CHECKOUT_DELETE_CHECKOUT="Del checkout: "

    DOCKER__PROFILE_MENUTITLE="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del "
    DOCKER__PROFILE_MENUTITLE+="env-variable ${DOCKER__FG_GREEN41}link${DOCKER__FG_GREEN}-${DOCKER__FG_GREEN119}checkout${DOCKER__NOCOLOR} ${DOCKER__FG_GREEN}Profile${DOCKER__NOCOLOR}"
    DOCKER__PROFILE_LOCATION_INFO_MSG="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__PROFILE_MENUOPTIONS_MSG="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__PROFILE_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__PROFILE_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__PROFILE_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__PROFILE_CHOOSE_PROFILE="Choose profile: "
    DOCKER__PROFILE_ADD_PROFILE="Add profile: "
    DOCKER__PROFILE_DELETE_PROFILE="Del profile: "
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
    docker__cacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCacheFpath=${DOCKER__EMPTYSTRING}
    docker__checkoutCacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCheckoutProfileCacheFpath=${DOCKER__EMPTYSTRING}

    docker__exp_env_var_menuTitle=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_locationInfo=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_locationInfo_fpath=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_menuOptions=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_option_choose=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_option_add=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_option_del=${DOCKER__EMPTYSTRING}

    docker__exitCode=0
}

docker__show_dockerList_files__sub() {
    #Show directory content
    show_dirContent__func "${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARK}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__FOURSPACES_F12_QUIT}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READ_DIALOG}" \
                        "${DOCKER__CONTAINER_ENV1}" \
                        "${DOCKER__CONTAINER_ENV2}" \
                        "${docker__repo_link_checkout_menu_select_out__fpath}" \
                        "${DOCKER__TABLEROWS}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_dirContent__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__repo_link_checkout_menu_select_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`
}

docker__generate_and_create_cache_filenames__sub() {
    #Generate cache-filenames (e.g. ltps_sunplus__latest__link.cache, ltps_sunplus__latest__checkout.cache)
    #Remarks:
    #   'outputResult' contains 2 outputs which are separated by  a 'SED__RS'.
    #   1. 'link_cache_fpath'
    #   2. 'checkout_cache_fpath'
    #   3. 'linkCheckoutProfile_cache_fpath'  
    local outputResult=`generate_cache_filenames_basedOn_specified_repositoryTag__func "${docker__docker_cache__dir}" "${docker__dockerFile_fpath}"`
    docker__linkCacheFpath=`echo "${outputResult}" | cut -d"${SED__RS}" -f1`
    docker__checkoutCacheFpath=`echo "${outputResult}" | cut -d"${SED__RS}" -f2`
    docker__linkCheckoutProfileCacheFpath=`echo "${outputResult}" | cut -d"${SED__RS}" -f3`

    #Create and write data to the cache-files.
    createAndWrite_data_to_cacheFiles_ifNotExist__func "${docker__linkCacheFpath}" \
                        "${docker__checkoutCacheFpath}" \
                        "${docker__linkCheckoutProfileCacheFpath}" \
                        "${docker__dockerFile_fpath}" \
                        "${docker__exported_env_var_fpath}"
}

docker__prep_input_args__sub() {
    case "${exp_env_var_type__input}" in
        ${DOCKER__LINK})
            docker__exp_env_var_menuTitle=${DOCKER__LINK_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__linkCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__LINK_LOCATION_INFO_MSG}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions=${DOCKER__LINK_MENUOPTIONS_MSG}
            docker__exp_env_var_option_choose=${DOCKER__LINK_CHOOSE_LINK}
            docker__exp_env_var_option_add=${DOCKER__LINK_ADD_LINK}
            docker__exp_env_var_option_del=${DOCKER__LINK_DELETE_LINK}

            docker__cacheFpath=${docker__linkCacheFpath}
            ;;
        ${DOCKER__CHECKOUT})
            docker__exp_env_var_menuTitle=${DOCKER__CHECKOUT_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__checkoutCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__CHECKOUT_LOCATION_INFO_MSG}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions=${DOCKER__CHECKOUT_MENUOPTIONS_MSG}
            docker__exp_env_var_option_choose=${DOCKER__CHECKOUT_CHOOSE_CHECKOUT}
            docker__exp_env_var_option_add=${DOCKER__CHECKOUT_ADD_CHECKOUT}
            docker__exp_env_var_option_del=${DOCKER__CHECKOUT_DELETE_CHECKOUT}

            docker__cacheFpath=${docker__checkoutCacheFpath}
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            docker__exp_env_var_menuTitle=${DOCKER__PROFILE_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__linkCheckoutProfileCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__PROFILE_LOCATION_INFO_MSG}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions=${DOCKER__PROFILE_MENUOPTIONS_MSG}
            docker__exp_env_var_option_choose=${DOCKER__PROFILE_CHOOSE_PROFILE}
            docker__exp_env_var_option_add=${DOCKER__PROFILE_ADD_PROFILE}
            docker__exp_env_var_option_del=${DOCKER__PROFILE_DELETE_PROFILE}

            docker__cacheFpath=${docker__linkCheckoutProfileCacheFpath}
            ;;
    esac
}

docker__show_choose_add_del_handler__sub() {
    #Execute script show/choose/add/del git-link(s)
    ${docker__show_choose_add_del_from_cache__fpath} "${docker__exp_env_var_menuTitle}" \
                        "${docker__exp_env_var_locationInfo}" \
                        "${docker__exp_env_var_menuOptions}" \
                        "${docker__exp_env_var_option_choose}" \
                        "${docker__exp_env_var_option_add}" \
                        "${docker__exp_env_var_option_del}" \
                        "${docker__exported_env_var_fpath}" \
                        "${docker__cacheFpath}" \
                        "${docker__show_choose_add_del_from_cache_out__fpath}" \
                        "${docker__dockerFile_fpath}" \
                        "${exp_env_var_type__input}" \
                        "${DOCKER__TIMEOUT_5}"

    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__show_choose_add_del_from_cache__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__show_dockerList_files__sub

    docker__generate_and_create_cache_filenames__sub

    docker__prep_input_args__sub

    docker__show_choose_add_del_handler__sub
}



#---EXECUTE
main_sub
