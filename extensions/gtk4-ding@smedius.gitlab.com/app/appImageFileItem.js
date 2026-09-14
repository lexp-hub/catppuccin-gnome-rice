/*
 * Adw-DING Copyright (C) 2022, 2025 Sundeep Mediratta (smedius@gmail.com)
 * Based on code original (C) Carlos Soriano and (c) Sergio Costas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import {Adw, Gio, GLib} from '../dependencies/gi.js';
import {FileItemIcon} from '../dependencies/localFiles.js';

import {_} from '../dependencies/gettext.js';

export {AppImageFileIcon};

const AppImageFileIcon = class extends FileItemIcon {
    _updateMetadataFromFileInfo(fileInfo) {
        super._updateMetadataFromFileInfo(fileInfo);

        this._isAppImageFile =
            this._attributeContentType === 'application/vnd.appimage';

        this._trusted =
            fileInfo.get_attribute_as_string('metadata::trusted') === 'true';

        if (this._useSandboxing === undefined)
            this._useSandboxing = true;
    }

    async onAllowDisallowLaunchingClicked() {
        if (this._destroying)
            return;

        if (this._isAppImageFile)
            await this.setMetadataTrusted(!this.trustedAppImageFile);

        await super.onAllowDisallowLaunchingClicked();
    }

    async _doOpenContext(context, fileList) {
        if (this._isAppImageFile) {
            try {
                await this._launchAppImageFile(context, fileList);
            } catch (e) {}

            return;
        }

        await super._doOpenContext(context, fileList);
    }

    async _launchAppImageFile(context, _fileList, forceNoSandbox = false) {
        if (this._writableByOthers || !this._attributeCanExecute) {
            const title = _('Invalid Permissions on AppImage File');
            const a =  _('This AppImage File has incorrect Permissions.');
            const aa = _('Right Click to edit Properties, then:');
            let error = `${a} ${aa}\n`;
            const b = _('Set Permissions, in');
            const c = _('Others Access');
            const d = _('Read Only');
            const e = _('or');
            const f = _('None');
            const g = _('Enable option');
            const h = _('Allow Executing File as a Program');
            if (this._writableByOthers)
                error += `\n${b} "${c}", "${d}" ${e} "${f}"`;

            if (!this._attributeCanExecute)
                error += `\n${g}, "${h}"`;

            this._showerrorpopup(title, error);
            return;
        }

        if (!this.trustedAppImageFile) {
            const title = _('Untrusted AppImage File');
            const a =
                _('This AppImage file is not trusted, it can not be launched.');
            const b = _('To enable launching, right-click, then:');
            const c = _('enable');
            const d = _('Allow Launching');

            const error = `${a} ${b}\n\n${c} "${d}"`;
            this._showerrorpopup(title, error);
            return;
        }

        if (forceNoSandbox)
            this._useSandboxing = false;

        if (this._launchWithHelper(context))
            return;

        if (await this._launchAppImageDirect())
            return;

        if (forceNoSandbox) {
            this._notifyLaunchFailed();
            return;
        }

        const launchWithLesserProtections =
            await this._warnLaunchWithLesserProtections();

        if (!launchWithLesserProtections)
            return;

        this._useSandboxing = false;
        if (await this._launchAppImageDirect(true))
            return;

        this._notifyLaunchFailed();
    }

    _launchWithHelper(context) {
        const helper = this._findLaunchHelper();
        if (!helper)
            return false;

        try {
            const launched = helper.launch_uris([this.uri], context);
            if (launched !== false)
                return true;
        } catch (e) {
            console.error(
                e,
                `Error launching AppImage helper for ${this.uri}: ${e.message}`
            );
        }

        return false;
    }

    _findLaunchHelper() {
        const appImageHandler =
            Gio.AppInfo.get_all_for_type(this.attributeContentType);

        for (const app of appImageHandler) {
            const appName = app.get_name()?.toLowerCase() ?? '';
            if (appName.includes('helper') ||
                appName.includes('launcher') ||
                appName.includes('kit'))
                return app;
        }

        if (appImageHandler.length)
            return appImageHandler[0];

        return null;
    }

    _launchAppImageDirect(useFallback = false) {
        let commandLine = `"${this._execLine}"`;
        if (useFallback || !this._useSandboxing)
            commandLine += ' --no-sandbox';

        console.log(`Launching ${commandLine}`);
        return new Promise(resolve => {
            let settled = false;
            const finish = result => {
                if (settled)
                    return;

                settled = true;
                resolve(result);
            };

            const pid = this.DesktopIconsUtil.spawnCommandLine(
                commandLine,
                null,
                () => finish(false)
            );

            if (!pid) {
                finish(false);
                return;
            }

            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
                finish(true);
                return GLib.SOURCE_REMOVE;
            });
        });
    }

    _warnLaunchWithLesserProtections() {
        const dialog = new Adw.AlertDialog();
        const window = this._desktopManager.getDialogParentWindow();

        dialog.set_body_use_markup(true);
        dialog.set_heading_use_markup(true);
        dialog.set_heading(_('AppImage Launch Failed'));
        dialog.set_body(
            _('This AppImage may need to be launched without sandboxing on this system.\n\nLaunch with <b>--no-sandbox</b>?')
        );

        dialog.add_response('cancel', _('Cancel'));
        dialog.add_response('launch', _('Launch with lesser protections'));
        dialog.set_close_response('cancel');
        dialog.set_default_response('launch');
        dialog.set_response_appearance(
            'launch',
            Adw.ResponseAppearance.SUGGESTED
        );
        dialog.set_response_appearance(
            'cancel',
            Adw.ResponseAppearance.DEFAULT
        );
        dialog.set_prefer_wide_layout(true);

        return new Promise(resolve => {
            dialog.choose(window, null, (actor, asyncResult) => {
                const response = actor.choose_finish(asyncResult);
                dialog.close();
                resolve(response === 'launch');
            });
        });
    }

    _notifyLaunchFailed() {
        this._desktopManager.dbusManager.doNotify(
            _('AppImage Launch Failed'),
            _('This AppImage could not be launched.')
        );
    }

    _addEmblemsToIconIfNeeded(iconPaintable, position = 0) {
        let emblem = null;
        let newIconPaintable = iconPaintable;

        if (this._isAppImageFile && !this.trustedAppImageFile) {
            emblem = Gio.ThemedIcon.new('ding-icon-emblem-unreadable');

            newIconPaintable =
                this._addEmblem(newIconPaintable, emblem, position);

            position += 1;
        }

        return super._addEmblemsToIconIfNeeded(newIconPaintable, position);
    }

    get isAppImageFile() {
        return this._isAppImageFile;
    }

    get trustedAppImageFile() {
        return this._isAppImageFile &&
        this._attributeCanExecute &&
        this.metadataTrusted &&
        !this._desktopManager.writableByOthers &&
        !this._writableByOthers;
    }
};
