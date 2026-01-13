// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#ifndef WINDOWS_HOST_API_H
#define WINDOWS_HOST_API_H

#include "messages.g.h"
#include <windows.h>
#include <fwpmu.h>

namespace x
{
    extern MessageFlutterApi* message_api;

    HANDLE _addSession(
         wchar_t *sessionName,
         wchar_t *providerName,
         wchar_t *sublayerName,
        const GUID *providerKey,
        const GUID *sublayerKey);

    class DisableDefaultDns
    {
    public:
        DisableDefaultDns();
        ~DisableDefaultDns();
        void Do(int64_t index);
        void Undo();

    private:
        HANDLE _engine{NULL};
    };

	class WindowsHostApiImpl : public WindowsHostApi
    {
    public:
        WindowsHostApiImpl();
        virtual ~WindowsHostApiImpl();

        std::optional<FlutterError> DisableDNS(int64_t index) override;
        std::optional<FlutterError> UndoDisableDNS() override;
        ErrorOr<bool> IsRunningAsAdmin() override;

    private:
        HANDLE _engine{NULL};
        std::unique_ptr<DisableDefaultDns> _disableDefaultDns;
        void _uninstallProvider();
    };

};
#endif
