#
# Copyright (C) 2019-2021 The Android-x86 Open Source Project
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

LOCAL_PATH := $(dir $(call my-dir))
LOCAL_ALSA_UCM_DIR := external/alsa-ucm-conf

# Build version.h
include $(CLEAR_VARS)

LOCAL_MODULE := alsa_utils_headers
LOCAL_MODULE_CLASS := HEADER_LIBRARIES

intermediates := $(call local-generated-sources-dir)

GEN := $(intermediates)/version.h
$(GEN): $(LOCAL_PATH)configure.ac
	@mkdir -p $(@D); \
	sed -n "/^AC_INIT.* \([0-9.]*\))/s//\#define SND_UTIL_VERSION_STR \"\1\"/p" $< > $@

LOCAL_GENERATED_SOURCES := $(GEN)

# Common flags
ALSA_UTILS_CFLAGS := \
	-Wno-absolute-value -Wno-enum-conversion -Wno-missing-field-initializers \
	-Wno-parentheses -Wno-pointer-arith -Wno-sign-compare \
	-Wno-unused-parameter -Wno-unused-variable

LOCAL_EXPORT_C_INCLUDE_DIRS := \
	$(dir $(GEN)) \
	$(LOCAL_PATH)include \
	$(LOCAL_PATH)android

include $(BUILD_HEADER_LIBRARY)

# Build amixer command
include $(CLEAR_VARS)

LOCAL_CFLAGS := $(ALSA_UTILS_CFLAGS) -D_GNU_SOURCE

LOCAL_SRC_FILES := \
	amixer/amixer.c \
	amixer/volume_mapping.c

LOCAL_MODULE := alsa_amixer
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_amixer $(TARGET_OUT)/bin/amixer

include $(BUILD_EXECUTABLE)

# Build aplay command
include $(CLEAR_VARS)

LOCAL_CFLAGS := $(ALSA_UTILS_CFLAGS)

LOCAL_SRC_FILES := \
	aplay/aplay.c

LOCAL_MODULE := alsa_aplay
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_aplay $(TARGET_OUT)/bin/aplay; \
						  ln -sf /system/bin/alsa_aplay $(TARGET_OUT)/bin/arecord

include $(BUILD_EXECUTABLE)

# Build alsactl command
include $(CLEAR_VARS)

LOCAL_CFLAGS := $(ALSA_UTILS_CFLAGS) \
	-DSYS_ASOUNDRC=\"/data/local/tmp/asound.state\" \
	-DSYS_LOCKFILE=\"/data/local/tmp/asound.state.lock\" \
	-DSYS_PIDFILE=\"/data/local/tmp/alsactl.pid\"

LOCAL_SRC_FILES := $(addprefix alsactl/,\
	alsactl.c \
	clean.c \
	daemon.c \
	info.c \
	init_parse.c \
	init_ucm.c \
	lock.c \
	monitor.c \
	state.c \
	utils.c)

LOCAL_MODULE := alsa_ctl
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_ctl $(TARGET_OUT)/bin/alsactl

include $(BUILD_EXECUTABLE)

# Build alsaucm command
include $(CLEAR_VARS)

LOCAL_CFLAGS := $(ALSA_UTILS_CFLAGS)

LOCAL_SRC_FILES := \
        alsaucm/dump.c \
        alsaucm/usecase.c \

LOCAL_MODULE := alsa_ucm
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers

###Copy the alsa-ucm-conf to /system/usr/share/alsa/ucm2
LOCAL_POST_INSTALL_CMD := $(hide) mkdir -p $(TARGET_OUT)/usr/share/alsa; \
						ln -sf /system/bin/alsa_ucm $(TARGET_OUT)/bin/alsaucm; \
						rsync -av -l $(LOCAL_ALSA_UCM_DIR)/ucm2 $(TARGET_OUT)/usr/share/alsa \
						--exclude codecs/qcom-lpass \
						--exclude OMAP \
						--exclude Qualcomm \
						--exclude 'README.md' \
						--exclude 'DEBUG.md' \
						--exclude Rockchip \
						--exclude Samsung \
						--exclude Terga

include $(BUILD_EXECUTABLE)

# Build alsaloop command
include $(CLEAR_VARS)

LOCAL_CFLAGS := $(ALSA_UTILS_CFLAGS)

LOCAL_SRC_FILES := \
        alsaloop/alsaloop.c \
        alsaloop/control.c \
        alsaloop/pcmjob.c

LOCAL_MODULE := alsa_loop
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_loop $(TARGET_OUT)/bin/alsaloop

include $(BUILD_EXECUTABLE)

# Build alsamixer command
include $(CLEAR_VARS)

LOCAL_CFLAGS := -std=c11 $(ALSA_UTILS_CFLAGS) \
	-DCURSESINC=\"ncurses.h\" -D_GNU_SOURCE

LOCAL_SRC_FILES := $(addprefix alsamixer/,\
	bindings.c \
	card_select.c \
	cli.c \
	colors.c \
	configparser.c \
	curskey.c \
	device_name.c \
	die.c \
	mainloop.c \
	mem.c \
	menu_widget.c \
	mixer_clickable.c \
	mixer_controls.c \
	mixer_display.c \
	mixer_widget.c \
	proc_files.c \
	textbox.c \
	utils.c \
	volume_mapping.c \
	widget.c)

LOCAL_MODULE := alsa_mixer
LOCAL_SHARED_LIBRARIES := libasound libncurses
LOCAL_STATIC_LIBRARIES := libmenu libpanel libform
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_mixer $(TARGET_OUT)/bin/alsamixer

include $(BUILD_EXECUTABLE)

# Build alsa_iecset command
include $(CLEAR_VARS)

LOCAL_CFLAGS := -g -Wall

LOCAL_SRC_FILES := \
	iecset/iecbits.c \
	iecset/iecset.c

LOCAL_MODULE := alsa_iecset
LOCAL_SHARED_LIBRARIES := libasound
LOCAL_HEADER_LIBRARIES := alsa_utils_headers
LOCAL_POST_INSTALL_CMD := ln -sf /system/bin/alsa_iecset $(TARGET_OUT)/bin/iecset

include $(BUILD_EXECUTABLE)

# Copy alsa-info.sh
include $(CLEAR_VARS)
LOCAL_MODULE := alsa-info.sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES := alsa-info/alsa-info.sh

include $(BUILD_PREBUILT)