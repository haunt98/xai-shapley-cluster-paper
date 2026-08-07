#set text(lang: "vi")
#set text(font: "New Computer Modern")
#set text(size: 11pt)

#set page(numbering: "1")

// Giá trị Shapley để giải thích độ chính xác của dự đoán

#outline(title: "Mục lục")

#pagebreak()

= Danh mục các từ viết tắt

#table(
  columns: (auto, auto, auto),
  stroke: 0.5pt,
  align: left,
  [*Từ viết tắt*], [*Nghĩa tiếng Anh*], [*Nghĩa tiếng Việt*],

  [AI], [Artificial Intelligence], [Trí tuệ nhân tạo],
  [ML], [Machine Learning], [Học máy],
  [XAI], [Explainable AI], [Trí tuệ nhân tạo giải thích được],
  [MSE], [Mean Squared Error], [Sai số bình phương trung bình],
  [KNN], [K-Nearest Neighbors], [K láng giềng gần nhất],
  [AAKR], [Auto-Associative Kernel Regression], [Phân loại bất thường],
)

#pagebreak()

= Chương 1. MỞ ĐẦU

// MỞ ĐẦU: giới thiệu tóm tắt về công trình nghiên cứu, lý do lựa chọn đề tài, câu hỏi nghiên cứu, mục đích, đối tượng, phạm vi nghiên cứu, phương pháp nghiên cứu, ý nghĩa khoa học hoặc thực tiễn của đề tài;

== 1.1. Giới thiệu tóm tắt về công trình nghiên cứu

Trong thập kỷ qua, AI đã trở thành công nghệ quan trọng trong nhiều ngành công nghiệp, ví dụ như:

- Y tế: Chẩn đoán bệnh theo triệu chứng lâm sàng, phân tích hình ảnh y tế (CT, MRI).
- Tài chính - Ngân hàng: Dự báo biến động thị trường, đánh giá rủi ro tín dụng và phát hiện gian lận giao dịch.
- Thương mại điện tử: Hệ thống gợi ý sản phẩm, phân tích hành vi người tiêu dùng.
- Giao thông: Xe tự động lái, tối ưu hoá lộ trình logistics.
- An ninh: Nhận diện khuôn mặt.

Đa phần các mô hình AI hiệu quả hiện nay đều có kiến trúc rất phức tạp với hàng triệu tham số. Với giá trị đầu vào đưa vào mô hình AI, không dễ gì dự đoán được kết quả đầu ra, việc giải thích tại sao thậm chí còn khó hơn. Vì vậy các mô hình AI này còn được gọi là các hộp đen (black box), chúng ta hoàn toàn không thể biết chính xác bên trong mô hình hoạt động cụ thể như thế nào. Tuy nhiên, bản chất hộp đen này khiến việc đặt niềm tin và triển khai AI trong các hệ thống đòi hỏi tính an toàn cao (safety critical systems) gặp nhiều khó khăn. Các phương pháp XAI ra đời nhằm cố gắng giải thích kết quả đầu ra của mô hình AI, củng cố niềm tin cho người dùng mô hình cũng như giúp cho nhà phát triển mô hình có thể cải thiện được kết quả tốt hơn.

Nghiên cứu này tập trung vào một cách tiếp cận mới trong XAI đó là giải thích *sai số của dự đoán* thay vì giải thích dự đoán. Trong thực tế khi có một vấn đề hay một sự cố xảy ra, ví dụ như sai sót khi mô hình dự đoán sai, thì chúng ta mới sử dụng phương pháp XAI để kiểm tra lại tại sao dự đoán sai thực tế. Đối với các phương pháp XAI vốn chỉ tập trung giải thích giá trị dự đoán mà không biết trước kết quả giá trị thực tế, thì kết quả giải thích sẽ chỉ phản ánh được tại sao đưa ra dự đoán chứ không thể giải thích được tại sao lại đưa ra dự đoán lỗi. Nghiên cứu này sẽ trình bày phương pháp XAI sử dụng giá trị thực tế đã được biết, xây dựng dựa trên phương pháp XAI giải thích dự đoán dựa trên mức độ đóng góp của từng cụm dữ liệu huấn luyện (data training cluster) thông qua Lý thuyết trò chơi liên minh Giá trị Shapley (Coalitional Game Theory Shapley values)

== 1.2. Lý do lựa chọn đề tài

Lý do lựa chọn đề tài xuất phát từ ba nội dung chính sau:

- *Khoảng trống nghiên cứu về phương pháp XAI giải thích cục bộ (local) cho sai số của dự đoán*: Sự phát triển của mô hình AI đi kèm với sự phát triển các phương pháp XAI giải thích cục bộ như LIME [TODO], ICE [TODO], PredDiff [TODO]. Tuy nhiên điểm chung của các phương pháp này là đều giải thích giá trị dự đoán khi chưa biết trước kết quả thực tế. Bên cạnh đó các phương pháp XAI giải thích cho sai số dự đoán hầu hết đều mang tính toàn cục (global), thể hiện dự đoán trên toàn bộ tập dữ liệu, chứ không dự đoán cho từng điểm dữ liệu riêng biệt. Cho nên hiện tại chưa có một phương pháp XAI nào giải thích cục bộ cho sai số dự đoán dựa trên tập dữ liệu mà không phụ thuộc vào mô hình (model agnostic).
- *Tiếp cận hướng dữ liệu:*: Nhiều phương pháp XAI tập trung vào đo lường mức độ quan trọng của các đặc trưng (feature) trong dự đoán, nhưng lại bỏ qua tầm quan trọng của tập dữ liệu huấn luyện. Trong thực tế, tập dữ liệu huấn luyện có thể đóng vai trò quyết định đến kết quả dự đoán của mô hình. Nếu tập dữ liệu huấn luyện bị thiên lệch (bias) thì kết quả đầu ra của mô hình cũng sẽ bị thiên lệch theo. Một ví dụ tương tự có thể thấy trong môn bóng rổ: Chiều cao là một đặc trưng rất quan trọng ảnh hưởng đến hiệu suất thi đấu bóng rổ. Tuy nhiên, nếu xét riêng trong giải đấu NBA chuyên nghiệp, nơi mà hầu hết các vận động viên đều đã sở hữu chiều cao vượt trội so với người bình thường, thì chiều cao lại không còn là yếu tố quan trọng có thể giải thích được sự chênh lệch về hiệu suất giữa các cầu thủ nữa. Điều này cho thấy vai trò của một đặc trưng có được coi là *quan trọng* hay không phụ thuộc hoàn toàn vào tập dữ liệu huấn luyện mà mô hình được học. Do đó, việc giải thích mô hình dưới góc nhìn hướng dữ liệu, cụ thể trong nghiên cứu này là đánh giá ảnh hưởng của từng cụm dữ liệu huấn luyện, là cần thiết để hiểu rõ bản chất và cải thiện độ chính xác dự đoán.
- *Nhu cầu thực tiễn trong phân tích sự cố*: Ở các hệ thống đòi hỏi tính an toàn cao, thách thức lớn nhất luôn nằm ở việc liệu các dự đoán của mô hình AI có thực sự chính xác và đáng tin cậy hay không. Câu hỏi tại sao mô hình đưa ra dự đoán như thế này không quan trọng bằng câu hỏi tại sao mô hình lại dự đoán lệch thực tế sau khi có mô hình AI dự báo say dẫn đến sự cố nghiêm trọng. Hiểu được điều này sẽ giúp các nhà phát triển mô hình sửa chữa, cập nhật mô hình tốt hơn và phòng ngừa các dự đoán sai lệch dẫn đến sự cố trong tương lai.

== 1.3. Câu hỏi nghiên cứu

Nhằm giải quyết khoảng trống nghiên cứu về giải thích sai số dự đoán cục bộ, đề tài tập trung vào việc trả lời các câu hỏi nghiên cứu sau:

- Làm thế nào để ứng dụng Giá trị Shapley từ Lý thuyết trò chơi liên minh nhằm xác định ảnh hưởng cục bộ của các cụm dữ liệu huấn luyện đến sai số dự đoán và độ chính xác phân loại trong bối cảnh giá trị thực tế đã biết?
- Các đặc tính lý thuyết của Giá trị Shapley thể hiện như thế nào trong bài toán giải thích sai số dự đoán cục bộ?
- Việc sử dụng kết quả giải thích có giúp xây dựng chiến lược thu thập dữ liệu huấn luyện mới nhằm cải thiện độ chính xác dự đoán của mô hình hay không?

== 1.4. Mục đích nghiên cứu

*Mục đích tổng quát:* Xây dựng phương pháp XAI mới nhằm giải thích cục bộ cho sai số dự đoán trong bối cảnh giá trị thực tế đã biết, không phụ thuộc vào mô hình, tập trung vào dữ liệu thay vì đặc trưng, để cuối cùng có thể tối ưu hóa cụm dữ liệu huấn luyện cho các mô hình AI.

Để đạt được mục đích trên, đề tài đề ra các mục tiêu cụ thể sau:

- *Về mặt lý thuyết:* Đề xuất phương pháp tính Giá trị Shapley cho các cụm dữ liệu huấn luyện để đánh giá sự đóng góp của từng cụm dữ liệu huấn luyện đến sai số dự đoán cục bộ trong bài toán hồi quy và bài toán phân loại. Đồng thời chứng minh các tính chất của Giá trị Shapley vẫn còn đúng đối với phương pháp này.
- *Về mặt ứng dụng:* Thử nghiệm phương pháp mới trên dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng, từ đó đề xuất chiến lược thu thập dữ liệu huấn luyện để tối ưu độ sai sót dự đoán của mô hình AI.

Phương pháp này mới là vì chưa có công trình nghiên cứu nào giải thích sai số trong dự đoán cục bộ, và cũng không nhiều công trình tiếp cận theo hướng dữ liệu cụ thể là nghiên cứu tập dữ liệu huấn luyện thay cho hướng nghiên cứu dựa trên đặc trưng vốn đã được nghiên cứu rộng rãi.

== 1.5. Đối tượng và Phạm vi nghiên cứu

Đối tượng nghiên cứu chính: Phương pháp XAI độc lập với mô hình dựa trên Lý thuyết trò chơi liên minh với Giá trị Shapley. Trong đó bao gồm mức độ đóng góp của các cụm dữ liệu huấn luyện đối với sai số dự đoán cục bộ, cụ thể là MSE trong bài toán hồi quy tuyến tính (Linear Regression) và độ chính xác (Accuracy) trong bài toán phân loại (Classification), với bối cảnh là biết trước giá trị thực tế.

Phạm vi nghiên cứu: Nghiên cứu tập trung vào giải thích độ đóng góp của cụm dữ liệu huấn luyện trong bài toán:

- Hồi quy tuyến tính với sai số MSE sử dụng mô hình AI Random Forest và KNN.
- Phân loại với độ chính xác Accuracy và thuật toán AAKR.

Tập dữ liệu thực nghiệm bao gồm:

- Dữ liệu tạo sinh (synthetic data) để kiểm chứng tính đúng đắn về mặt toán học của phương pháp.
- Dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng tại thành phố [TODO].

Giới hạn của nghiên cứu:

- Nghiên cứu không đề xuất cách phân cụm mới cho tập dữ liệu huấn luyện, mà sử dụng các phương pháp phân cụm tự nhiên hoặc có sẵn của dữ liệu
- Nghiên cứu không đề xuất công thức đánh giá sai số dự đoán mới mà sử dụng lại sai số có sẵn như MSE.

== 1.6. Phương pháp nghiên cứu

== 1.7. Ý nghĩa khoa học và thực tiễn

#pagebreak()

= Chương 2. TỔNG QUAN

// TỔNG QUAN về vấn đề nghiên cứu: phân tích, đánh giá các công trình nghiên cứu liên quan trực tiếp đến đề tài luận văn đã được công bố ở trong và ngoài nước, chỉ ra những vấn đề mà luận văn sẽ tập trung giải quyết, xác định mục tiêu của đề tài, nội dung và phương pháp nghiên cứu;

#pagebreak()

= Chương 3. PHƯƠNG PHÁP NGHIÊN CỨU

// PHƯƠNG PHÁP NGHIÊN CỨU: cơ sở lý thuyết, lý luận, cách tiếp cận vấn đề nghiên cứu;

#pagebreak()

= Chương 4. KẾT QUẢ NGHIÊN CỨU VÀ PHÂN TÍCH, ĐÁNH GIÁ, THẢO LUẬN

= Chương 5. KẾT LUẬN VÀ KIẾN NGHỊ

// KẾT LUẬN VÀ KIẾN NGHỊ: trình bày những phát hiện mới, những kết luận rút ra từ kết quả nghiên cứu; kiến nghị về những nghiên cứu tiếp theo;

= DANH MỤC TÀI LIỆU THAM KHẢO
