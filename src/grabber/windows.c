#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>
#include <setupapi.h>
#include <initguid.h>

#include "uploader.h"

#define NAME_SIZE 128

const GUID GUID_CLASS_MONITOR = {0x4d36e96e, 0xe325, 0x11ce, 0xbf, 0xc1,
								 0x08, 0x00, 0x2b, 0xe1, 0x03, 0x18};

static void parse_edid(IN HDEVINFO DeviceInfoSet,
	IN PSP_DEVINFO_DATA DeviceInfoData, char **output, int *output_len) {
	HKEY hDevRegKey;
	DWORD uniID[123];

	// NULL BOTH?
	if (SetupDiGetDeviceRegistryProperty(
		DeviceInfoSet, DeviceInfoData, SPDRP_DEVICEDESC, NULL, (PBYTE)(&uniID),
		sizeof(uniID), NULL
	)) {
		printf("UID: %s\n", (char *) uniID);
	} else {
		printf("ERROR: %d\n", (int) GetLastError());
	}

	hDevRegKey = SetupDiOpenDevRegKey(
		DeviceInfoSet, DeviceInfoData, DICS_FLAG_GLOBAL, 0, DIREG_DEV,
		KEY_ALL_ACCESS
	);

	if (hDevRegKey) {
		LONG retValue, i;
		DWORD dwType, AcutalValueNameLength = NAME_SIZE;

		unsigned char EDIDdata[1024];
		DWORD j, edidsize = sizeof(EDIDdata);

		int old_output_len = *output_len;

		*output_len += 1024;

		*output = realloc(*output, *output_len * sizeof(char));
		memset(*output + old_output_len, 0, 1024);

		for (i = 0, retValue = ERROR_SUCCESS; retValue != ERROR_NO_MORE_ITEMS;
			i++) {
			char valueName[NAME_SIZE];
			char hex_char[3];

			retValue = RegEnumValue(
				hDevRegKey, i, &valueName[0], &AcutalValueNameLength, NULL,
				&dwType, EDIDdata, &edidsize
			);

			if (retValue == ERROR_SUCCESS ) {
				if (!strcmp(valueName, "EDID")) {
					*output = strcat(*output, "\n\n\tEDID:");
				}

				for (j = 0; j < edidsize; j++) {
					if (j % 16 == 0) {
						*output = strcat(*output, "\n\t\t");
					}

					sprintf(hex_char, "%02X", EDIDdata[j]);
					*output = strcat(*output, hex_char);
				}
			}

			break;
		}

        // XRandR parser expects some text after EDID data
        // or it will ignore last EDID item
        *output = strcat(*output, "\nDone.\n");

		*output_len = strlen(*output);

		RegCloseKey(hDevRegKey);
	} else {
		printf("ERROR: %d\n", (int) GetLastError());
	}
}

int grab_edids() {
	HDEVINFO DeviceInfoSet = NULL;
	SP_DEVINFO_DATA DeviceInfoData;
	ULONG i;

	char *output = NULL;
	int output_len = 0;

	do {
		DeviceInfoSet = SetupDiGetClassDevsEx(
			&GUID_CLASS_MONITOR, NULL, NULL, DIGCF_PRESENT, NULL, NULL, NULL
		);
		// DIGCF_PRESENT: Return only devices that are currently present.
		// DIGCF_PROFILE: Return all cached devices.

		if (DeviceInfoSet == INVALID_HANDLE_VALUE) {
			printf("Error: %d", (int) GetLastError());
			break;
		}

		for (i=0; ERROR_NO_MORE_ITEMS != GetLastError(); i++) {
			memset(&DeviceInfoData, 0, sizeof(DeviceInfoData));
			DeviceInfoData.cbSize = sizeof(DeviceInfoData);

			if (SetupDiEnumDeviceInfo(DeviceInfoSet, i, &DeviceInfoData)) {
				parse_edid(DeviceInfoSet, &DeviceInfoData, &output, &output_len);
			}
		}
	} while (FALSE);

    // Upload EDID data
	upload_text(output, "xrandr");

	free(output);

	printf("\n");
	system("pause");

	return EXIT_SUCCESS;
}