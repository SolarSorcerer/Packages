import gi
import json
import subprocess
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class MainAppWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Application Manager")
        self.set_border_width(10)
        self.set_default_size(300, 200)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.add(vbox)

        self.create_button("Install Applications", vbox, self.on_install_clicked)
        self.create_button("Add Application", vbox, self.on_add_clicked)
        self.create_button("Remove Application", vbox, self.on_remove_clicked)
        self.create_button("Exit", vbox, self.on_exit_clicked)

    def create_button(self, label, container, event_method):
        button = Gtk.Button(label=label)
        button.connect("clicked", event_method)
        container.pack_start(button, True, True, 0)

    def on_install_clicked(self, widget):
        self.open_install_application_dialog()


    def on_add_clicked(self, widget):
        self.open_add_application_dialog()

    def on_remove_clicked(self, widget):
        self.open_remove_application_dialog()

    def on_exit_clicked(self, widget):
        print("Exiting")
        Gtk.main_quit()

    def open_install_application_dialog(self):
        dialog = Gtk.Dialog(title="Install Applications", parent=self)
        dialog.set_default_size(400, 300)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, "Install Selected", Gtk.ResponseType.OK)

        content_area = dialog.get_content_area()
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_min_content_height(200)
        content_area.pack_start(scrolled_window, True, True, 0)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        scrolled_window.add_with_viewport(vbox)

        # Load applications and create a checkbox for each
        checkboxes = []
        try:
            with open('packages.json', 'r') as file:
                data = json.load(file)
                for app_id in data['packages']:
                    checkbox = Gtk.CheckButton(label=app_id)
                    vbox.pack_start(checkbox, False, False, 0)
                    checkboxes.append(checkbox)
        except Exception as e:
            self.show_message_dialog(f"Failed to load applications: {str(e)}")
            dialog.destroy()
            return

        # Select All checkbox
        select_all = Gtk.CheckButton(label="Select All")
        select_all.connect("toggled", self.on_select_all_toggled, checkboxes)
        content_area.pack_start(select_all, False, False, 0)

        dialog.show_all()
        response = dialog.run()

        if response == Gtk.ResponseType.OK:
            selected_apps = [cb.get_label() for cb in checkboxes if cb.get_active()]
            self.install_flatpak_applications(selected_apps)  # Adjusted this line


        dialog.destroy()

    def install_flatpak_applications(self, app_ids):
        if not app_ids:
            self.show_message_dialog("No applications selected for installation.")
            return
        
        installed_apps = []
        failed_apps = []

        for app_id in app_ids:
            try:
                # Execute the Flatpak install command
                subprocess.run(["flatpak", "install", "-y", "flathub", app_id], check=True)
                installed_apps.append(app_id)
            except subprocess.CalledProcessError:
                failed_apps.append(app_id)

        if installed_apps:
            success_message = "Successfully installed: " + ", ".join(installed_apps)
            self.show_message_dialog(success_message)
        
        if failed_apps:
            fail_message = "Failed to install: " + ", ".join(failed_apps)
            self.show_message_dialog(fail_message)

    def on_select_all_toggled(self, select_all_cb, checkboxes):
        for cb in checkboxes:
            cb.set_active(select_all_cb.get_active())


    def open_add_application_dialog(self):
        dialog = Gtk.Dialog(title="Add Application", parent=self, flags=0)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK)

        dialog_box = dialog.get_content_area()
        entry = Gtk.Entry()
        entry.set_placeholder_text("Flatpak ID")
        dialog_box.pack_start(entry, True, True, 0)

        dialog.show_all()
        response = dialog.run()

        if response == Gtk.ResponseType.OK:
            app_id = entry.get_text()
            self.add_application(app_id)

        dialog.destroy()

    def add_application(self, app_id):
        if not app_id:
            self.show_message_dialog("No application ID provided.")
            return

        try:
            with open('packages.json', 'r+') as file:
                data = json.load(file)
                if app_id in data['packages']:
                    self.show_message_dialog(f"Application {app_id} already exists in the list.")
                    return
                data['packages'].append(app_id)
                file.seek(0)
                json.dump(data, file, indent=4)
                file.truncate()
                self.show_message_dialog(f"Application {app_id} added successfully.")
        except Exception as e:
            self.show_message_dialog(f"Failed to add application: {str(e)}")

    def open_remove_application_dialog(self):
        dialog = Gtk.Dialog(title="Remove Application", parent=self, flags=0)
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, "Remove", Gtk.ResponseType.OK)

        dialog_box = dialog.get_content_area()
        combo_box = Gtk.ComboBoxText()
        combo_box.set_entry_text_column(0)

        try:
            with open('packages.json', 'r') as file:
                data = json.load(file)
                for app_id in data['packages']:
                    combo_box.append_text(app_id)
        except Exception as e:
            self.show_message_dialog(f"Failed to load applications: {str(e)}")
            dialog.destroy()
            return

        combo_box.set_active(0)
        dialog_box.pack_start(combo_box, True, True, 0)
        dialog.show_all()
        response = dialog.run()

        if response == Gtk.ResponseType.OK:
            app_id = combo_box.get_active_text()
            if app_id:
                self.remove_application(app_id)

        dialog.destroy()

    def remove_application(self, app_id):
        try:
            with open('packages.json', 'r+') as file:
                data = json.load(file)
                if app_id in data['packages']:
                    data['packages'].remove(app_id)
                    file.seek(0)
                    json.dump(data, file, indent=4)
                    file.truncate()
                    self.show_message_dialog(f"Application {app_id} removed successfully.")
                else:
                    self.show_message_dialog(f"Application {app_id} not found.")
        except Exception as e:
            self.show_message_dialog(f"Failed to remove application: {str(e)}")

    def show_message_dialog(self, message):
        dialog = Gtk.MessageDialog(parent=self, flags=0, message_type=Gtk.MessageType.INFO, buttons=Gtk.ButtonsType.OK, text=message)
        dialog.run()
        dialog.destroy()

def main():
    window = MainAppWindow()
    window.connect("destroy", Gtk.main_quit)
    window.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
