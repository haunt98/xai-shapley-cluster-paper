#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, shapes

#set text(lang: "vi")
#set text(font: "New Computer Modern")
#set text(size: 11pt)

#set page(numbering: "1")
#set math.equation(numbering: "(1)")

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
- Phân loại với độ chính xác Accuracy và mô hình AI AAKR.

Tập dữ liệu thực nghiệm bao gồm:

- Dữ liệu tạo sinh (synthetic data) để kiểm chứng tính đúng đắn về mặt toán học của phương pháp.
- Dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng tại thành phố [TODO].

Giới hạn của nghiên cứu:

- Nghiên cứu không đề xuất cách phân cụm mới cho tập dữ liệu huấn luyện, mà sử dụng các phương pháp phân cụm tự nhiên hoặc có sẵn của dữ liệu
- Nghiên cứu không đề xuất công thức đánh giá sai số dự đoán mới mà sử dụng lại sai số có sẵn như MSE.

== 1.6. Phương pháp nghiên cứu

- *Về mặt lý thuyết*: Nghiên cứu sử dụng Lý thuyết trò chơi liên minh với Giá trị Shapley để định nghĩa mô hình trò chơi cho cụm dữ liệu huấn luyện. Bao gồm các tính chất của Giá trị Shapley, đề xuất và chứng minh các công thức liên quan. Đồng thời giải thích ý nghĩa Giá trị Shapley cho từng cụm dữ liệu huấn luyện trong bối cảnh giải thích sai số dự đoán cục bộ.
- *Về mặt ứng dụng*: Nghiên cứu sử dụng dữ liệu thực nghiệm, để kiểm chứng tính đúng đắn phương pháp, đồng thời đánh giá hiệu quả của phương pháp trong việc giải thích sai số dự đoán cục bộ. Dữ liệu thực nghiệm bao gồm dữ liệu tạo sinh và dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng. Các mô hình AI được sử dụng bao gồm Random Forest, KNN và AAKR.

== 1.7. Ý nghĩa khoa học và thực tiễn

- *Ý nghĩa khoa học:* Đề xuất phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng nhờ vào Lý thuyết trò chơi liên minh và Giá trị Shapley. Phương pháp này có thể được áp dụng cho nhiều mô hình AI khác nhau, không bị giới hạn bởi một mô hình cụ thể. Đồng thời nghiên cứu cung cấp một góc nhìn mới về tư duy theo hướng dữ liệu, cụ thể là về cách giải thích đóng góp của từng cụm dữ liệu huấn luyện đối với sai số dự đoán, từ đó giúp các nhà nghiên cứu và phát triển mô hình AI hiểu rõ hơn về cách dữ liệu huấn luyện ảnh hưởng đến kết quả dự đoán.
- *Ý nghĩa thực tiễn:* Phương pháp này có thể giúp các nhà phát triển mô hình AI xác định cụm dữ liệu huấn luyện nào là quan trọng, từ đó tối ưu hóa tập dữ liệu huấn luyện để cải thiện độ chính xác dự đoán của mô hình. Ngoài ra, việc giải thích sai số dự đoán cục bộ sau khi vận hành thực tế hoặc khi có sự cố xảy ra sẽ giúp các nhà phát triển mô hình AI phát hiện và khắc phục các vấn đề trong dữ liệu huấn luyện, từ đó nâng cao độ tin cậy và hiệu quả của các hệ thống AI trong các ứng dụng thực tiễn có tính rủi ro cao.

#pagebreak()

= Chương 2. TỔNG QUAN

// TỔNG QUAN về vấn đề nghiên cứu: phân tích, đánh giá các công trình nghiên cứu liên quan trực tiếp đến đề tài luận văn đã được công bố ở trong và ngoài nước, chỉ ra những vấn đề mà luận văn sẽ tập trung giải quyết, xác định mục tiêu của đề tài, nội dung và phương pháp nghiên cứu;

== 2.1. Các công trình nghiên cứu liên quan

XAI được sinh ra để cung cấp cho người dùng và nhà phát triển các công cụ để hiểu rõ hơn về cách mà mô hình AI đưa ra dự đoán. Ví dụ như một mô hình AI quyết định cho vay tín dụng thì kết quả chỉ có thể là quyết định cho vay hoặc không, nhưng khi khách hàng hỏi lại kỹ hơn tại sao lại từ chối yêu cầy vay vốn thì lúc đó cần phải giải thích rõ hơn ví dụ như khách hàng có lịch sử tín dụng xấu, hoặc vì một tiêu chuẩn nào đó khác. XAI còn được dùng để kiểm chứng mô hình có học được đúng các đặc trưng như nhà phát triển mong muốn hay không. Ví dụ với một mô hình AI phân loại loài gấu, giữa gấu bắc cực và gấu nâu, có khả năng mô hình học đặc trưng màu sắc của tuyết để phân biệt thay vì học đặc trưng về màu sắc hay hình dáng cơ thể của hai loài gấu.

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    align: left,
    [*Toàn cục hay cục bộ*], [*Hướng đặc trưng hay dữ liệu*], [*Phương pháp*],

    table.cell(rowspan: 2)[*Toàn cục*],
    [Đặc trưng],
    [SAGE [TODO] \
      Permutation feature importance [TODO] \
      ALEPlots [TODO]
    ],

    [Dữ liệu],
    [Data Banzhaf [TODO] \
      Cook’s distance [TODO]
    ],

    table.cell(rowspan: 2)[*Cục bộ*],
    [Đặc trưng],
    [Marginal Shapley values [TODO] \
      Conditional Shapley values [TODO] \
      PredDiff [TODO] \
      Anchors [TODO] \
      Counterfactual explanations [TODO] \
      LIME [TODO] \
      ICE [TODO]
    ],

    [Dữ liệu],
    [Influence functions for perturbing training data [TODO] \
      Case-based explanations [TODO] \
      Shapley values for cluster importance [TODO]
    ],
  ),
  caption: [Phân loại các phương pháp XAI theo phạm vi và đối tượng giải thích],
  placement: none,
) <table-overview>

@table-overview tổng hợp các phương pháp XAI được phân loại theo hai tiêu chí: phạm vi giải thích (toàn cục hay cục bộ) và đối tượng giải thích (đặc trưng hay dữ liệu huấn luyện). Một số phương pháp XAI cung cấp giải thích toàn cục, nghĩa là giải thích toàn bộ mô hình AI, từng thành phần của mô hình đóng góp đến toàn bộ dự đoán như thế nào. Trong khi các phương pháp khác cung cấp giải thích cục bộ, nghĩa là giải thích từng dự đoán riêng lẻ một của mô hình tại từng thời điểm cụ thể. Một khác biệt quan trọng nữa giữa các phương pháp XAI là giải thích dựa trên đặc trưng hay là dữ liệu huấn luyện. Các phương pháp XAI toàn cục có thể chia làm 2 nhóm là phân tích ảnh hưởng của các đặc trưng khác nhau ví dụ như: *SAGE* [TODO], *Permutation feature importance* [TODO] và *ALEPlots* [TODO] hoặc đánh giá sử dụng dữ liệu huấn luyện ví dụ như: *Data Banzhaf* [TODO].

Bên cạnh hướng giải thích toàn cục là hướng cục bộ, để giải thích từng dự đoán đơn lẻ tại từng thời điểm cục bộ, ta cũng có thể chia thành 2 nhóm phương pháp XAI dựa trên mức độ quan trọng của đặc trưng hoặc dựa trên mức độ ảnh hưởng của cụm dữ liệu huấn luyện đến dự đoán. Nhóm thứ nhất có thể kể đến như Marginal Shapley values [TODO], Conditional Shapley values [TODO], PredDiff [TODO], Anchors [TODO], Counterfactual explanations [TODO], LIME [TODO] và ICE [TODO]. Nhóm thứ hai có thể kể đến như Influence functions for perturbing training data [TODO], Case-based explanations [TODO] và Shapley values for cluster importance [TODO]. Nhóm thứ nhất chứa các phương pháp XAI phổ biến và được trích dẫn nhiều nhất trong các công trình nghiên cứu khác. Nhóm thứ hai, tập trung vào dữ liệu, thì lại ít phương pháp hơn. Có 3 phương pháp có thể kể đến là:

- *Influence functions for perturbing training data* [TODO] để khảo sát mức độ nhạy cảm của dự đoán đối với các nhiễu loạn nhỏ trong tập dữ liệu huấn luyện.
- *Case-based explanations* [TODO] mục đích là để dùng các ví dụ dự đoán trong quá khứ để kiểm tra và giải thích cho các ví dụ trong tương lai.
- *Shapley values for cluster importance* [TODO] là một cách tiếp cận đánh giá mức độ ảnh hưởng của từng cụm dữ liệu huấn luyện nhỏ trong tập dữ liệu huấn luyện đến dự đoán của mô hình AI.

Bài nghiên cứu này sẽ dựa trên phương pháp *Shapley values for cluster importance* [TODO] làm nền tảng để phát triển thành phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng.

== 2.2. Giá trị Shapley trong Trò chơi liên minh

Giá trị Shapley được phát triển bởi [TODO] trong lĩnh vực Lý thuyết trò chơi liên minh để giải quyết bài toán chia lợi ích công bằng giữa các người chơi trong một trò chơi liên minh. Giả sử có một trò chơi với liên minh $N$ người chơi. Sau khi chơi xong, liên minh sẽ được nhận phần thường là $v(N)$. Lấy ví dụ trò chơi câu cá, người chơi là những người đi câu cá, và phần thưởng là số cá câu được.

Bài toàn đặt ra là làm thể nào để chia phần thưởng công bằng cho từng người chơi. Nếu toàn bộ người chơi cùng tham gia thì tổng phần thưởng là $v(N)$, nếu mỗi lần chơi chỉ có một tập con $S subset N$ người chơi tham gia, thì phần thưởng nhận được là $v(S)$. Ta định nghĩa hàm tính phần thưởng $v$ là một ánh xạ từ liên minh $S$ và ra phần thưởng là số thực $v : 2^(|N|) arrow.r RR$. Một người chơi $i$, có thể tham gia nhiều liên minh $S$ khác nhau. Dựa vào đóng góp của người chơi trong toàn bộ các liên minh mà tính ra được phần thưởng mà người chơi xứng đáng được nhận.

Có nhiều cách để tính phần thưởng cho người chơi, trong nội dung bài nghiên cứu này sẽ sử dụng Giá trị Shapley, công thức được tham khảo từ [TODO] như sau:

#figure(
  $
    phi_i = sum_(S subset.eq N backslash {i}) (|S|!(|N| - |S| - 1)!) / (|N|!) dot [v(S union {i}) - v(S)]
  $,
) <math-shapley-value-1>

@math-shapley-value-1 chính là giá trị trung bình toàn bộ phần chênh lệch giữa phần thưởng tất cả các liên minh có người chơi $i$ tham gia $S union {i})$ và phần thưởng tất cả các liên minh còn lại không có người chơi $i$. Với trò chơi câu cá, chúng ta so sánh toàn bộ số cá câu được khi có người chơi $i$ tham gia và không có người chơi $i$ tham gia trong toàn bộ liên minh có thể lập ra để tính ra phần thưởng của người chơi.

Từ công thức @math-shapley-value-1, có thể hiểu Giá trị Shapley của người chơi $i$ là trung bình giá trị đóng góp (marginal contribution) theo hoán vị tương ứnng của các liên minh. Do đó có thể viết lại công thức Giá trị Shapley tương đương như sau:

#figure(
  $
    phi_i = 1 / (|N|!) sum_(cal(O) in pi(|N|)) [v("Pre"^i (cal(O)) union {i}) - v("Pre"^i (cal(O)))]
  $,
) <math-shapley-value-2>

Trong đó:

- $pi(|N|)$ là tập hợp tất cả các hoán vị của $N$ người chơi.
- $"Pre"^i (cal(O))$ là tập hợp tất cả người chơi có vị trí ở trước người chơi $i$ khi sắp xếp trong hoán vị $cal(O) in pi(|N|)$.

Giá trị Shapley có 4 tính chất cơ bản sau:

- Tính *hiệu quả* (Efficiency): Toàn bộ phần thưởng đều được chia hết cho từng người chơi (sau khi chia xong thì không còn phần thưởng nào).

#figure(
  $
    sum_(i in N) phi_i = v(N)
  $,
) <math-shapley-value-efficiency>

- Tính *đối xứng* (Symmetry): Nếu chúng ta có

#figure(
  $
    v(S union {i}) = v(S union {j})
  $,
) <math-shapley-value-symmetry>

mà mọi liên minh $S subset.eq N$ đều không chứa $i$ và $j$, thì phần thưởng của hai người chơi này phải bằng nhau $phi_i = phi_j$.


- Tính *tuyến tính* (Linearity): Nếu chúng ta có hai trò chơi với hai hàm phần thưởng khác nhau $v$ và $w$, thì phần thưởng của người chơi trong trò chơi tổng hợp sẽ bằng tổng phần thưởng của người chơi trong từng trò chơi riêng lẻ.

#figure(
  $
    phi_i(v + w) = phi_i(v) + phi_i(w)
  $,
) <math-shapley-value-linearity-1>

cho mọi $i in N$. Bên cạnh đó, với mọi số thực $a$, ta cũng có

#figure(
  $
    phi_i(a v) = a phi_i(v)
  $,
) <math-shapley-value-linearity-2>

cho mọi $i in N$.

- *Người chơi zero* (Null player): Người chơi zero là người chơi có đóng góp bằng 0 $phi_i = v(zero.slashed)$, nghĩa là
$v({i}) = v(zero.slashed)$  và $v(S union i) = v(S)$ cho toàn bộ liên minh $S subset.eq N$. Thông thường ta ngầm hiểu rằng $v(zero.slashed) = 0$.

Quay lại ví dụ về trò chơi câu cá, giả sử có 3 người chơi $A$, $B$, $C$. @demo-fish-1 thể hiện phần thưởng cho toàn bộ liên minh có thể xảy ra. Có thể thấy nếu cả 3 người chơi đều tham gia thì phần thưởng là lớn nhất. Bên cạnh đó người chơi $B$ và người chơi $C$ đều có đóng góp như nhau vì $v({A, B}) = v({A, C})$, nên theo tính đối xứng thì Giá trị Shapley của $B$ và $C$ là giống nhau.


#figure(
  table(
    columns: (auto, auto),
    align: (left, right),

    [*Liên minh*], [*Số cá câu được*],

    [$A, B, C$], [100],
    [$A, B$], [70],
    [$A, C$], [70],
    [$B, C$], [20],
    [$A$], [30],
    [$B$], [20],
    [$C$], [20],
    [$emptyset$], [0],
  ),
  caption: [
    Phần thưởng (số lượng cá) cho từng liên minh của người chơi câu cá.
  ],
)<demo-fish-1>

Để tính Giá trị Shapley, chúng ta cần tính toàn bộ phần chênh lệch đóng góp theo toàn bộ hoán vị có thể có cho từng người chơi. @demo-fish-2 tính cho người chơi $A$, @demo-fish-3 tính cho người chơi $B$ và nguời chơi $C$ vì $B$ và $C$ có Giá trị Shapley giống nhau.


#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*],
    [*$S union {k}$*],
    [*$S$*],
    [*$f_(cal(O) union {i})$*],
    [*$f_cal(O)$*],
    [*$f_(cal(O) union {k}) - f_cal(O)$*],

    [${A, B, C}$], [${A}$], [$emptyset$], [30], [0], [30],
    [${A, C, B}$], [${A}$], [$emptyset$], [30], [0], [30],
    [${B, A, C}$], [${A, B}$], [${B}$], [70], [20], [50],
    [${B, C, A}$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
    [${C, A, B}$], [${A, C}$], [${C}$], [70], [20], [50],
    [${C, B, A}$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
  ),
  caption: [
    Bảng phục vụ tính Giá trị Shapley cho người chơi $A$
  ],
) <demo-fish-2>

#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*],
    [*$S union {k}$*],
    [*$S$*],
    [*$f_(cal(O) union {i})$*],
    [*$f_cal(O)$*],
    [*$f_(cal(O) union {k}) - f_cal(O)$*],

    [${A, B, C}$], [$\{A, B\}$], [$\{A\}$], [70], [30], [40],
    [${A, C, B}$], [$\{A, B, C\}$], [$\{A, C\}$], [100], [70], [30],
    [${B, A, C}$], [$\{B\}$], [$\{emptyset\}$], [20], [0], [20],
    [${B, C, A}$], [$\{B\}$], [$\{emptyset\}$], [20], [0], [20],
    [${C, A, B}$], [$\{A, B, C\}$], [$\{A, C\}$], [100], [70], [30],
    [${C, B, A}$], [$\{B, C\}$], [$\{C\}$], [20], [20], [0],
  ),
  caption: [
    Bảng phục vụ tính Giá trị Shapley cho người chơi $B$
  ],
) <demo-fish-3>

Cuối cùng, Giá trị Shapley của từng người chơi chính là trung bình của toàn bộ phần chênh lệch đóng góp của toàn bộ hoán vị.

$
  phi_A = (30 + 30 + 50 + 80 + 50 + 80) / 6 approx 53.3
$

$
  phi_B = phi_C = (40 + 30 + 20 + 20 + 30 + 0)∕6 approx 23.3
$

Kiểm tra lại tính hiệu quả $phi_A + phi_B + phi_C = 100$ đúng với @demo-fish-1.

== 2.3. Giá trị Shapley đối với sự quan trọng của đặc trưng

Nếu thay đổi trò chơi thành bài toán hồi quy, cụ thể là dự đoán kết quả các đặc trưng, ta vẫn có thể áp dụng Giá trị Shapley để giải thích. Xét một bài toán máy học tiêu chuẩn: có tập huấn luyện $cal(D)^("train")$ với $J$ đặc trưng $x_1, ..., x_J$ và giá trị $y$ là kết quả cần dự đoán, dùng để huấn luyện mô hình $f : cal(A) arrow.r RR$ với $cal(A) in cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Các đặc trưng đóng vai như người chơi trong trò chơi dự đoán kết quả này, mục đích là để tìm mức độ đóng góp của từng đặc trưng ảnh hưởng đến kết quả dự đoán tại một điểm dữ liệu cụ thể $x$.

Công thức tính phần thưởng cũng như là mức độ đóng góp của đặc trưng được định nghĩa như sau:

$
  v(S)(x) = sum_(z in cal(A)) p(z)(f(tau(x, z, S)) - f(z))
$ <math-shapley-value-feature-reward>

với $tau(x, z, S) = (u_1, ..., u_J)$ với điều kiện $u_j = x_j$ nếu $j in S$ và $u_j = z_j$ nếu $j in.not S$. $z$ là điểm dữ liệu ngẫu nhiên (random data points) vẫn lấy từ không gian $cal(A)$, $p(z)$ là phân phối của các điểm dữ liệu ngẫu nhiên $z$ trong không gian $cal(A)$.

Do đó công thức tính Giá trị Shapley cho đặc trưng $j$ là:

$
  phi_j(x) = frac(1, J!) sum_(cal(O) in pi(J)) sum_(z in A) p(z) [f(tau(x, z, "Pre"^j (cal(O) union {j}))) - f(tau(x, z, "Pre"^j (cal(O))))]
$ <math-shapley-value-feature-1>

với $pi(J)$ là tập hợp tất cả các hoán vị của tập $J$ đặc trưng, $"Pre"^j (cal(O))$ là tập hợp tất cả các đặc trưng có vị trí ở trước đặc trưng $j$ khi sắp xếp trong hoán vị $cal(O) in pi(J)$. Và vì $f(z)$ đều xuất hiện trong công thức $v("Pre"^j (cal(O) union {j}))$ và $v("Pre"^j (cal(O)))$, nên chúng bị triệt tiêu, không xuất hiện trong @math-shapley-value-feature-1. Để đơn giản chúng ta giả sử tập $cal(A)$ là rời rạc.

Tuy nhiên thông thường chúng ta không biết được phân phối $p(z)$, và số các liên minh của $N$ đặc trưng là $2^(|N|)$ khi số đặc trưng tăng lên thì số các liên minh cũng tăng lên rất nhanh, nên việc tính chính xác $v(S)$ gần như là không thể. Để đơn giản hơn, [TODO] đề xuất sử dụng phân phối mẫu ngẫu nhiên (random sampling) và thuật toán xấp xỉ đề viết lại Giá trị Shapley xấp xỉ như sau:

$
  hat(phi)_j (x) = 1/M sum_(m=1)^M [f(tau(x, z^m, "Pre"^j (cal(O)^m union {j}))) - f(tau(x, z^m, "Pre"^j (cal(O)^m)))]
$ <math-shapley-value-feature-2>

@math-shapley-value-feature-2 thay vì tìm toàn bộ hoán vị của toàn bộ liên minh, thay vào đó chỉ lấy $M$ mẫu ngẫu nhiên. Với từng mẫu ngẫu nhiên $m$, ta có được hoán vị $cal(O) in pi(J)$ và điểm dữ liệu $z^m in cal(A)$ theo phân phối $p$.$p$. Vì $p$ không biết nên khi tính toàn ta lấy mẫu theo tập dữ liệu [TODO].


== 2.4. Giá trị Shapley đối với sự quan trọng của cụm dữ liệu

Dựa trên Giá trị Shapley đối với sự quan trọng của đặc trưng, bài báo *Shapley values for cluster importance* [TODO] đề xuất phương pháp XAI mới để giải thích mức độ quan trọng của từng cụm dữ liệu trong tập dữ liệu huấn luyện thay vì đặc trưng trong dự đoán. Trò chơi và phần thưởng vẫn được định nghĩa tương tự, chúng ta thay đổi định nghĩa người chơi trở thành các tập con trong tập dữ liệu huấn luyện, để nhằm giải thích dự đoán bị ảnh hưởng bởi các cụm dữ liệu huấn luyện như thế nào.

Như ở chương trước, chúng ta vẫn sẽ sử dụng hàm hồi quy để minh hoạ $f : cal(A) arrow.r RR$ với $cal(A) in cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu $cal(Q)_k$ không giao nhau, sao cho $cal(Q)_1 union ... union cal(Q)_K$ chính là toàn bộ tập dữ liệu huấn luyện $cal(D)^("train")$. Cách chia cụm dữ liệu huấn luyện ảnh hưởng trực tiếp đến việc giải thích dự đoán. Ví dụ có thể chia thành các cụm theo thời gian, cụ thể là 12 tháng trong năm. Hoặc lấy riêng từng điểm dữ liệu làm từng cụm cụ thể, lúc này thay vì trả lời cho câu hỏi cụm dữ liệu nào ảnh hưởng đến kết quả dự đoán thì sẽ trả lời cho câu hỏi điểm dữ liệu cụ thể nào ảnh hưởng đến kết quả dự đoán nhất.

Trò lại với trò chơi liên minh, các cụm $cal(Q)_k$ là người chơi và hàm phần thường được định nghĩa như sau:

$
  v(S)(x) = f_S (x)
$ <math-shapley-value-cluster-reward>

trong đó $f_S (x)$ là hàm dự đoán được huấn luyện từ hợp của các $cal(Q)_k$ với $k in S subset.eq N$.

Giá trị Shapley cho cụm dữ liệu $k$ được định nghĩa như sau:

$
  phi_k(x) = frac(1, K!) sum_(cal(O) in pi(K)) (f_("Pre"^k (cal(O) union {k}))(x) - f_("Pre"^k (cal(O)))(x))
$ <math-shapley-value-cluster-1>

trong đó $pi(K)$ là tập hợp tất cả các hoán vị của tập $K$ cụm dữ liệu, $"Pre"^k (cal(O))$ là tập hợp tất cả các cụm dữ liệu có vị trí ở trước cụm dữ liệu $k$ khi sắp xếp trong hoán vị $cal(O) in pi(K)$.

Áp dụng cách xấp xỉ tương tự như @math-shapley-value-feature-2, ta có thể viết lại công thức Giá trị Shapley cho cụm dữ liệu $k$ một cách xấp xỉ như sau:

$
  hat(phi)_k (x) = 1/M sum_(m=1)^M (f_("Pre"^k (cal(O)^m union {k}))(x) - f_("Pre"^k (cal(O)^m))(x))
$

Với từng mẫu ngẫu nhiên $m$, ta có được hoán vị $cal(O) in pi(K)$ lấy ngẫu nhiên theo phân phối uniform [TODO].

Đối với trường hợp chúng ta không có dữ liệu, tương đương với $S = zero.slashed$, ta định nghĩa dự đoán bằng $0$, tương đương với $f_zero.slashed (x) = 0$ với mọi $x in cal(A)$. Điều này tương đương với tính chất người chơi zero trong Giá trị Shapley $v(zero.slashed) = 0$, nghĩa là nếu không có dữ liệu huấn luyện thì dự đoán sẽ bằng 0.

#pagebreak()

= Chương 3. PHƯƠNG PHÁP NGHIÊN CỨU

// PHƯƠNG PHÁP NGHIÊN CỨU: cơ sở lý thuyết, lý luận, cách tiếp cận vấn đề nghiên cứu;

Nghiên cứu này sử dụng cách tiếp cận Giá trị Shapley đối với sự quan trọng của cụm dữ liệu, nhưng thay vì giải thích dự đoán, nghiên cứu này sẽ giải thích sai số dự đoán. Đối với bài toán hồi quy, chỉ số đánh giá cho sai số dự đoán thường là sai số tuyệt đối (absolute error) hoặc sai số bình phương (squared error). @math-shapley-value-feature-reward và @math-shapley-value-cluster-reward đều có thể chỉnh sửa để sử dụng các loại chỉ số này để đánh giá. Nghiên cứu này chọn sai số bình phương để đánh giá sai số dự đoán.

#diagram(
  spacing: (10mm, 7mm),
  node-stroke: 1pt,
  edge-stroke: 0.8pt,

  // Q_1, Q_2, ..., Q_K
  node(
    (1.0, 0),
    text(fill: white)[$Q_1$],
    shape: "circle",
    fill: blue.darken(30%),
    stroke: black + 1pt,
    width: 10mm,
    height: 10mm,
    name: <q1>,
  ),
  node(
    (2.0, 0),
    text(fill: white)[$Q_2$],
    shape: "circle",
    fill: blue.darken(30%),
    stroke: black + 1pt,
    width: 10mm,
    height: 10mm,
    name: <q2>,
  ),
  node((2.5, 0), $[dots]$, stroke: none, name: <q-dots>),
  node(
    (3.5, 0),
    text(fill: white)[$Q_K$],
    shape: "circle",
    fill: blue.darken(30%),
    stroke: black + 1pt,
    width: 10mm,
    height: 10mm,
    name: <qk>,
  ),

  // D_train
  node(
    (2.5, 1.5),
    $cal(D)^"train"$,
    shape: shapes.ellipse,
    stroke: black + 1pt,
    width: 20mm,
    height: 15mm,
    name: <dtrain>,
  ),

  // D_test
  node(
    (4.0, 2.5),
    align(center)[$cal(D)^"test"$\ #v(0.5mm) $x$ \& $y$],
    shape: shapes.ellipse,
    stroke: black + 1pt,
    width: 20mm,
    height: 15mm,
    name: <dtest>,
  ),

  // Black box
  node(
    (2.5, 3.5),
    [Black box],
    shape: "rect",
    fill: luma(80%),
    stroke: black + 1.2pt,
    corner-radius: 4pt,
    width: 30mm,
    height: 15mm,
    name: <bbox>,
  ),

  // Loss formula
  node(
    (2.5, 5.0),
    $(f(x) - y)^2$,
    stroke: none,
    name: <loss>,
  ),

  node(
    (2.5, 6.5),
    align(center)[
      #v(2mm)
      value function
      #v(3mm)
      #text(fill: green.darken(20%), weight: "bold")[
        COALITIONAL\ GAME
      ]
      #v(3mm)
      K players
      #v(2mm)
    ],
    shape: "rect",
    stroke: green.darken(20%) + 1.2pt,
    corner-radius: 12pt,
    width: 45mm,
    name: <cgame>,
  ),

  node(
    (2.5, 8.5),
    align(center)[
      The Shapley values\
      $phi_1(x), phi_2(x), ..., phi_K(x)$
    ],
    stroke: none,
    name: <shapley>,
  ),

  edge(<dtrain>, <q1>, "->", stroke: (dash: "dashed")),
  edge(<dtrain>, <q2>, "->", stroke: (dash: "dashed")),
  edge(<dtrain>, <q-dots>, "->", stroke: (dash: "dashed")),
  edge(<dtrain>, <qk>, "->", stroke: (dash: "dashed")),

  edge(<dtrain>, <bbox>, "->", stroke: (dash: "dashed")),

  edge(<dtest>, <bbox>, "->", label: [$x$], corner: right, stroke: (
    dash: "dashed",
  )),
  edge(<dtest>, <loss>, "->", label: [$y$], corner: right, stroke: (
    dash: "dashed",
  )),
  edge(<bbox>, <loss>, "->", label: [$f(x)$], stroke: (dash: "dashed")),

  edge(<q1>, <cgame>, "->", label: [player], corner: left, stroke: (
    dash: "dashed",
  )),
  edge(<cgame>, <shapley>, "->", stroke: (dash: "dashed")),
)

== 3.1. Giải thích cục bộ

== 3.2. Giải thích toàn cục

== 3.3. Bài toán phân loại

#pagebreak()

= Chương 4. KẾT QUẢ NGHIÊN CỨU VÀ PHÂN TÍCH, ĐÁNH GIÁ, THẢO LUẬN

== 4.1. Dữ liệu tạo sinh

== 4.2. Dữ liệu Bikeshare

= Chương 5. KẾT LUẬN VÀ KIẾN NGHỊ

// KẾT LUẬN VÀ KIẾN NGHỊ: trình bày những phát hiện mới, những kết luận rút ra từ kết quả nghiên cứu; kiến nghị về những nghiên cứu tiếp theo;

= DANH MỤC TÀI LIỆU THAM KHẢO
