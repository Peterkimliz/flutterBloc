// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:plug/controllers/chat_controller.dart';
// import 'package:plug/controllers/user_controller.dart';
// import 'package:plug/models/work.dart';
// import 'package:plug/utils/style.dart';
// import 'package:plug/widgets/common_text.dart';
// import '../../controllers/service_controller.dart';
// import '../profile/components/image_container.dart';
//
// class RequestsPage extends StatefulWidget {
//   const RequestsPage({super.key});
//
//   @override
//   State<RequestsPage> createState() => _RequestsPageState();
// }
//
// class _RequestsPageState extends State<RequestsPage> {
//   final ServiceController serviceController = Get.find<ServiceController>();
//
//   final UserController userController = Get.find<UserController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.5,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//             onPressed: () => Get.back(),
//             icon: const Icon(Icons.arrow_back_ios)),
//         title: const CommonText(color: blackColor, text: "Requests"),
//       ),
//       body:
//
//       Obx(() {
//         return serviceController.fetchingJobs.value
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : serviceController.myJobs.isEmpty
//                 ? const Center(
//                     child: CommonText(
//                     color: blackColor,
//                     text: "No Completed jobs yet!",
//                     size: 16,
//                   ))
//                 : userController.currentProfile.value?.id ==
//                         FirebaseAuth.instance.currentUser?.uid
//                     ? ReorderableListView(
//                         onReorder: (oldIndex, newIndex) {
//                           setState(() {
//                             if (newIndex > oldIndex) {
//                               newIndex -= 1;
//                             }
//                             final item =
//                                 serviceController.myJobs.removeAt(oldIndex);
//                             serviceController.myJobs.insert(newIndex, item);
//                             Get.find<ChatController>()
//                                 .updateRequestPositions(serviceController.myJobs);
//                           });
//                         },
//                         children: serviceController.myJobs
//                             .map((work) => ListTile(
//                                   key: Key(work.position.toString()),
//                                   title: jobCard(work),
//                                 ))
//                             .toList(),
//                       )
//                     : ListView.builder(
//                         itemCount: serviceController.myJobs.length,
//                         shrinkWrap: true,
//                         itemBuilder: (context, index) {
//                           Work work = serviceController.myJobs.elementAt(index);
//                           return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 3),
//                               child: jobCard(work));
//                         });
//       }),
//     );
//   }
//
//   Widget jobCard(work) {
//     return Container(
//         padding: const EdgeInsets.all(10),
//         margin: const EdgeInsets.only(
//           bottom: 10,
//         ),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: const LinearGradient(
//               colors: [
//                 linearGradientTwo,
//                 linearGradientOne,
//               ],
//               stops: [
//                 0.0,
//                 1.0
//               ],
//               begin: FractionalOffset.topLeft,
//               end: FractionalOffset.bottomRight,
//               tileMode: TileMode.clamp),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 CommonText(
//                   color: whiteColor,
//                   text: work.provider!.service!.name!,
//                   size: 16,
//                 ),
//                 CommonText(
//                   color: whiteColor,
//                   text: DateFormat("MMM dd yyyy")
//                       .format(work.time!)
//                       .capitalize!
//                       .capitalize!,
//                   size: 16,
//                   fontFamily: "RedHatLight",
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: whiteColor,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           work.provider!.id ==
//                                   FirebaseAuth.instance.currentUser?.uid
//                               ? profileImage(
//                                   upload: true,
//                                   showCam: false,
//                                   radi: 12,
//                                   context: context,
//                                   imageProvider: work.provider!.profileUrl ==
//                                           null
//                                       ? const AssetImage(
//                                           "assets/images/profile.png")
//                                       : NetworkImage(
//                                               work.provider!.profileUrl ?? "")
//                                           as ImageProvider)
//                               : profileImage(
//                                   upload: true,
//                                   showCam: false,
//                                   radi: 12,
//                                   context: context,
//                                   imageProvider:
//                                       work.userId!.profileUrl == null
//                                           ? const AssetImage(
//                                               "assets/images/profile.png")
//                                           : NetworkImage(
//                                                   work.userId!.profileUrl ?? "")
//                                               as ImageProvider),
//                           const SizedBox(width: 3),
//                           CommonText(
//                             color: blackColor,
//                             text:
//                                 "${work.provider!.id == FirebaseAuth.instance.currentUser?.uid ? work.userId!.firstname : work.provider!.firstname!}",
//                             size: 15,
//                           ),
//                         ],
//                       ),
//                       if (work.isLive == true)
//                         const Icon(Icons.video_call_sharp, color: blueColor)
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           CommonText(
//                             color: blueColor,
//                             text: "\$${work.price! * work.hours!}",
//                             size: 15,
//                           ),
//                           CommonText(
//                             color: blueColor,
//                             text: "/ ${work.workType}",
//                             fontFamily: "RedHatLight",
//                             size: 15,
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 15, vertical: 5),
//                         decoration: BoxDecoration(
//                             color: work.status == "pending"
//                                 ? yellowColor
//                                 : Colors.green,
//                             borderRadius: BorderRadius.circular(30)),
//                         child: CommonText(
//                           color: whiteColor,
//                           text: work.status.toString().capitalize!,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     work.reviewMessage ?? '',
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 3,
//                     style: const TextStyle(
//                       fontFamily: "RedHatLight",
//                       color: blackColor,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ));
//   }
// }
