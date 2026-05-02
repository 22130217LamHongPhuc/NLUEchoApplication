import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ListHistoryEcho extends StatelessWidget {
  const ListHistoryEcho({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhật ký Echo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: 10,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) => historyEchoItem(),
          ),
        ),

      ],
    );
  }

  Widget historyEchoItem (){
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.green,
                  ),
                )
      
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
      
          Expanded(child: _card()),
        ],
      ),
    );
  }

  Widget _card() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Địa điểm: Thư viện trung tâm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Hôm qua lúc 14:30',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,

              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chill with coding',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,

              ),
            ),
            SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/hoa_anh_dao.jpg',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
