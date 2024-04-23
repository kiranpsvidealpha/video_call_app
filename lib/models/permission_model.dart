class PermissionDetail {
  String permission;
  bool status;
  PermissionDetail({
    required this.permission,
    required this.status,
  });
}

List<PermissionDetail> permissionDetails = [
  PermissionDetail(
    permission: "camera",
    status: false,
  ),
  PermissionDetail(
    permission: "location",
    status: false,
  ),
  PermissionDetail(
    permission: "storage",
    status: false,
  ),
  PermissionDetail(
    permission: "microphone",
    status: false,
  ),
];
